# -*- encoding : utf-8 -*-
class Network::NewCustomerApplication
  STATUS_DEFAULT    = 0
  STATUS_SENT       = 1
  STATUS_CANCELED   = 2
  STATUS_CONFIRMED  = 3
  STATUS_COMPLETE   = 4
  STATUS_IN_BS      = 5
  STATUSES = [ STATUS_DEFAULT, STATUS_SENT, STATUS_CANCELED, STATUS_CONFIRMED, STATUS_COMPLETE, STATUS_IN_BS ]
  NETWORK_OPERATIONS = [
    116,   # prepayment
    1000,  # charge: new_customer_application
    1006,  # penalty I
    1007,  # penalty II
    120,   # penalty III
    1008,  # charge correction
    1009,  # penalty I correction
    1010,  # penalty II correction
  ]
  VOLTAGE_220 = '220'
  VOLTAGE_380 = '380'
  VOLTAGE_610 = '6/10'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Network::RsName
  include Sys::VatPayer
  include Network::CalculationUtils

  belongs_to :user, class_name: 'Sys::User'
  field :number,    type: String
  field :payment_id, type: Integer
  field :rs_tin,    type: String
  field :rs_name,   type: String
  field :mobile,    type: String
  field :email,     type: String
  field :address,   type: String
  field :work_address, type: String
  field :address_code, type: String
  field :bank_code,    type: String
  field :bank_account, type: String
  field :status,     type: Integer, default: STATUS_DEFAULT
  field :personal_use, type: Mongoid::Boolean, default: true
  field :notes, type: String
  # გამოთვლის დეტალები და ბილინგთან კავშირი
  field :need_resolution,  type: Mongoid::Boolean, default: true
  field :voltage,     type: String
  field :power,       type: Float
  field :amount,      type: Float, default: 0
  field :days,        type: Integer, default: 0
  field :customer_id, type: Integer
  ### დღეების ანგარიში ###
  # send_date, არის თარიღი, როდესაც მოხდა განცხადების თელასში გამოგზავნა
  field :send_date, type: Date
  # start_date, არის თარიღი, როდესაც თელასმა განხცადება წამოებაში მიიღო
  field :start_date, type: Date
  # plan_end_date / end_date, არის თარიღი (გეგმიური / რეალური), როდესაც დასრულდება
  # ამ განცხადებით გათვალიწინებული ყველა სამუშაო
  field :plan_end_date, type: Date
  field :plan_end_date_changed_manually, type: Boolean
  field :end_date, type: Date
  # cancelation_date არის გაუქმების თარიღი
  field :cancelation_date, type: Date
  # factura fields
  field :factura_id, type: Integer
  field :factura_seria, type: String
  field :factura_number, type: Integer
  field :need_factura, type: Mongoid::Boolean, default: true
  field :show_tin_on_print, type: Mongoid::Boolean, default: true
  # aviso id
  field :aviso_id, type: Integer

  # embeds_many :items, class_name: 'Network::NewCustomerItem', inverse_of: :application
  has_many :files, class_name: 'Sys::File', inverse_of: 'mountable'
  has_many :messages, class_name: 'Sys::SmsMessage', as: 'messageable'
  has_many :requests, class_name: 'Network::RequestItem', as: 'source'

  validates :user, presence: { message: 'user required' }
  validates :rs_tin, presence: { message: I18n.t('models.network_new_customer_application.errors.tin_required') }
  validates :mobile, presence: { message: I18n.t('models.network_new_customer_application.errors.mobile_required') }
  # validates :email, presence: { message: I18n.t('models.network_new_customer_application.errors.email_required') }
  validates :address, presence: { message: I18n.t('models.network_new_customer_application.errors.address_required') }
  validates :address_code, presence: { message: I18n.t('models.network_new_customer_application.errors.address_code_required') }
  validates :bank_code, presence: { message: I18n.t('models.network_new_customer_application.errors.bank_code_required') }
  validates :bank_account, presence: { message: I18n.t('models.network_new_customer_application.errors.bank_account_required') }
  validates :voltage, presence: { message: 'required!' }
  validates :power, numericality: { message: I18n.t('models.network_new_customer_item.errors.illegal_power') }
  validate :validate_rs_name, :validate_number, :validate_mobile
  before_save :status_manager, :calculate_total_cost, :upcase_number, :prepare_mobile
  before_create :init_payment_id

  # Checking correctess of 
  def self.correct_number?(number); not not (/^(CNS|TCNS|1TCNS|3TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) end

  def customer; Billing::Customer.find(self.customer_id) if self.customer_id.present? end
  def billing_items
    if @__billing_items
      @__billing_items
    elsif self.customer_id.present?
      @__billing_items = Billing::Item.where(custkey: self.customer_id, billoperkey: NETWORK_OPERATIONS).order('itemkey DESC')
    else
      @__billing_items = []
    end
  end
  def payments; self.billing_items.select { |x| x.billoperkey == 116 } end
  def paid; self.payments.map{ |x| x.amount }.inject{ |sum, x| sum + x } || 0  end
  def remaining; if self.amount.present? then self.amount - self.paid else 0 end end
  def unit
    if self.voltage == '6/10' then I18n.t('models.network_new_customer_item.unit_kvolt')
    else I18n.t('models.network_new_customer_item.unit_volt') end
  end
  def bank_name; Bank.bank_name(self.bank_code) end
  def effective_number; self.number.blank? ? self.payment_id : self.number end

  def self.status_name(status); I18n.t("models.network_new_customer_application.status_#{status}") end
  def self.status_icon(status)
    case status
    # when STATUS_DEFAULT    then '/icons/mail-open.png'
    when STATUS_SENT       then '/icons/mail-send.png'
    when STATUS_CANCELED   then '/icons/cross.png'
    when STATUS_CONFIRMED  then '/icons/clock.png'
    when STATUS_COMPLETE   then '/icons/tick.png'
    when STATUS_IN_BS      then '/icons/lock.png'
    else '/icons/mail-open.png' end
  end
  def status_name; Network::NewCustomerApplication.status_name(self.status) end
  def status_icon; Network::NewCustomerApplication.status_icon(self.status) end
  def can_send_to_item?; self.status == STATUS_COMPLETE end #and self.items.any? end
  def formatted_mobile; KA::format_mobile(self.mobile) if self.mobile.present? end

  # შესაძლო სტატუსების ჩამონათვალი მიმდინარე სტატუსიდან.
  def transitions
    case self.status
    when STATUS_DEFAULT then [ STATUS_SENT, STATUS_CANCELED ]
    when STATUS_SENT then [ STATUS_DEFAULT, STATUS_CONFIRMED, STATUS_CANCELED ]
    when STATUS_CONFIRMED then [ STATUS_COMPLETE, STATUS_CANCELED ]
    when STATUS_COMPLETE then [ STATUS_CANCELED ]
    when STATUS_IN_BS then [ STATUS_CANCELED ]
    when STATUS_CANCELED then [] # NB: ძალიან მნიშვნელოვანია, რომ გაუქმებული განცხადება ვერ აღდგეს!!!
    else [ ]
    end
  end

  # # ახდენს სინქრონიზაციას BS.CUSTOMER ცხრილთან.
  # def sync_accounts!
  #   customers = Billing::Customer.where(custsert: self.number)
  #   customers.each do |customer|
  #     related = self.items.where(customer_id: customer.custkey).first || Network::NewCustomerItem.new(application: self, customer_id: customer.custkey)
  #     related.rs_tin = customer.taxid
  #     related.address = customer.address.to_s.to_ka
  #     related.address_code = '180.180.180.test'
  #     related.save
  #   end
  # end

  def real_days; (self.end_date || Date.today) - self.send_date end

  # პირველი ეტაპის ჯარიმა.
  def penalty_first_stage
    if self.send_date and self.start_date
      if real_days > days then self.amount / 2
      else 0 end
    else 0 end
  end

  # მეორე ეტაპის ჯარიმა.
  def penalty_second_stage
    if self.send_date and self.start_date
      if real_days > 2 * days then self.amount / 2
      else 0 end
    else 0 end
  end

  # მესამე ეტაპის ჯარიმა (კომპენსაცია).
  def penalty_third_stage
    if self.send_date and self.start_date
      r_days = self.real_days
      if r_days > 2*days then
        ((r_days-2*days-1).to_i/days)*self.amount/2
      else 0 end
    else 0 end
  end

  # ჯარიმის სრული ოდენობა.
  def total_penalty; self.penalty_first_stage + self.penalty_second_stage + self.penalty_third_stage end
  # რეალურად გადასახდელი თანხა.
  def effective_amount; self.amount - self.total_penalty end

  # ვალის გადანაწილების დათვლა.
  def calculate_distribution!
    items = self.items
    total_amount = (self.remaining * 100).to_i
    if items.any? and total_amount > 0
      per_item = total_amount / items.size
      remainder = total_amount - per_item * items.size
      items.each do |x|
        addition = 0
        addition = 1 and remainder -= 1 if remainder > 0
        x.amount = (per_item + addition) / 100.0
        x.save
      end
    end
  end

  # ბილინგში გაგზავნა.
  def send_to_bs!
    Billing::Item.transaction do
      # --> შემოწმება, რომ ყველა აბონენტი დაკავშირებულია
      items_without_customer = self.items.where(customer_id: nil)
      raise 'ყველა აბონენტი არაა აბონირებული!' if items_without_customer.any?
      # --> დავალიანების გადათვლა
      self.calculate_distribution!
      # --> განაწილება
      if self.items.count == 1
        item = self.items.first
        customer = item.customer
        account  = customer.accounts.first
        amount = self.amount
        item_date = self.end_date
        # set customer exception status
        customer.except = true
        customer.save!
        # find zdeposit customer
        network_customer = Billing::NetworkCustomer.where(customer: customer).first
        raise "სადეპოზიტო აბონენტი ვერ მოიძებნა!" if network_customer.blank?
        network_customer.exception_end_date = item_date + (self.personal_use ? 20 : 10)
        network_customer.save!
        # bs.item - charge operation
        bs_item = Billing::Item.new(billoperkey: 1000, acckey: account.acckey, custkey: customer.custkey,
          perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: amount,
          enterdate: Time.now, itemcatkey: 0)
        bs_item.save!
        network_item = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: amount,
          operkey: 1000, enterdate: Time.now, operdate: item_date, perskey: 1)
        network_item.save!
        # I. bs.item - first stage penalty
        first_stage = -self.penalty_first_stage
        if first_stage < 0
          bs_item1 = Billing::Item.new(billoperkey: 1006, acckey: account.acckey, custkey: customer.custkey,
            perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: first_stage,
            enterdate: Time.now, itemcatkey: 0)
          bs_item1.save!
          network_item1 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: first_stage,
            operkey: 1006, enterdate: Time.now, operdate: item_date, perskey: 1)
          network_item1.save!
        end
        # II. bs.item - second stage penalty
        second_stage = -self.penalty_second_stage
        if second_stage < 0
          bs_item2 = Billing::Item.new(billoperkey: 1007, acckey: account.acckey, custkey: customer.custkey,
            perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: second_stage,
            enterdate: Time.now, itemcatkey: 0)
          bs_item2.save!
          network_item2 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: second_stage,
            operkey: 1007, enterdate: Time.now, operdate: item_date, perskey: 1)
          network_item2.save!
        end
        # III. bs.item - third stage penalty
        third_stage = -self.penalty_third_stage
        if third_stage < 0
          bs_item3 = Billing::Item.new(billoperkey: 120, acckey: account.acckey, custkey: customer.custkey,
            perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: third_stage,
            enterdate: Time.now, itemcatkey: 0)
          bs_item3.save!
          network_item3 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: third_stage,
            operkey: 120, enterdate: Time.now, operdate: item_date, perskey: 1)
          network_item3.save!
        end
      else
        raise 'ეს სიტუაცია ჯერ არაა მზად!'
      end
    end
    # update application status
    self.status = STATUS_IN_BS
    self.save
  end

  def factura_sent?; not self.factura_seria.blank? end
  def can_send_factura?; self.need_factura and [STATUS_COMPLETE, STATUS_IN_BS].include?(self.status) and not self.factura_sent? and self.effective_amount > 0 end

  private

  def calculate_total_cost
    tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power)
    if tariff
      if power > 0
        tariff_days = self.need_resolution ? tariff.days_to_complete : tariff.days_to_complete_without_resolution
        self.amount = tariff.price_gel
        self.days = tariff_days
        if self.send_date and not self.plan_end_date_changed_manually
          self.plan_end_date = self.send_date + self.days
        end
        self.amount = (self.amount / 1.18 * 100).round / 100.0 unless self.pays_non_zero_vat?
      end
    else
      if power > 0
        self.amount = nil
        self.days = nil
      end
    end
  end

  def validate_number
    if self.status != STATUS_DEFAULT and self.number.blank?
      self.errors.add(:number, I18n.t('models.network_new_customer_application.errors.number_required'))
    elsif self.number.present?
      self.errors.add(:number, 'არასწორი ფორმატი!') unless Network::NewCustomerApplication.correct_number?(self.number)
    end
  end

  def validate_mobile
    if self.mobile.present? and not KA::correct_mobile?(self.mobile)
      self.errors.add(:mobile, I18n.t('models.network_new_customer_application.errors.mobile_incorrect'))
    end
  end

  def status_manager
    if self.status_changed?
      case self.status
      when STATUS_DEFAULT   then self.send_date = nil
      when STATUS_SENT      then self.send_date  = Date.today
      when STATUS_CONFIRMED then self.start_date = Date.today and self.plan_end_date = self.send_date + self.days
      when STATUS_COMPLETE  then self.end_date   = Date.today
      when STATUS_CANCELED  then
        self.cancelation_date = Date.today
        revert_bs_operations_on_cancel
      end
    end
  end

  def revert_bs_operations_on_cancel
    if self.status_was == STATUS_IN_BS
      amnt3 = penalty_third_stage
      raise "კომპენსაციის კორექტირება არ ვიცი როგორ გავაკეთო!" if amnt3 > 0
      Billing::Item.transaction do
        item_date = Date.today
        amnt1 = penalty_first_stage
        amnt2 = penalty_second_stage
        if self.items.count == 1
          item = self.items.first
          customer = item.customer
          account  = customer.accounts.first
          amount = self.amount
          item_date = Date.today
          # set customer exception status
          customer.except = false
          customer.save!
          # find zdeposit customer
          network_customer = Billing::NetworkCustomer.where(customer: customer).first
          raise "სადეპოზიტო აბონენტი ვერ მოიძებნა!" if network_customer.blank?
          network_customer.exception_end_date = nil
          network_customer.save!
          # bs.item - rollback charge operation
          bs_item = Billing::Item.new(billoperkey: 1008, acckey: account.acckey, custkey: customer.custkey,
            perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: (-amount),
            enterdate: Time.now, itemcatkey: 0)
          bs_item.save!
          network_item = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: (-amount),
            operkey: 1008, enterdate: Time.now, operdate: item_date, perskey: 1)
          network_item.save!
          # I. bs.item - first stage penalty
          if amnt1 > 0
            bs_item1 = Billing::Item.new(billoperkey: 1009, acckey: account.acckey, custkey: customer.custkey,
              perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: amnt1,
              enterdate: Time.now, itemcatkey: 0)
            bs_item1.save!
            network_item1 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: amnt1,
              operkey: 1009, enterdate: Time.now, operdate: item_date, perskey: 1)
            network_item1.save!
          end
          # II. bs.item - second stage penalty
          if amnt2 > 0
            bs_item2 = Billing::Item.new(billoperkey: 1010, acckey: account.acckey, custkey: customer.custkey,
              perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: amnt2,
              enterdate: Time.now, itemcatkey: 0)
            bs_item2.save!
            network_item2 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: amnt2,
              operkey: 1010, enterdate: Time.now, operdate: item_date, perskey: 1)
            network_item2.save!
          end
          # # III. bs.item - third stage penalty
          # third_stage = -self.penalty_third_stage
          # if third_stage < 0
          #   bs_item3 = Billing::Item.new(billoperkey: 120, acckey: account.acckey, custkey: customer.custkey,
          #     perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: third_stage,
          #     enterdate: Time.now, itemcatkey: 0)
          #   bs_item3.save!
          #   network_item3 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: third_stage,
          #     operkey: 120, enterdate: Time.now, operdate: item_date, perskey: 1)
          #   network_item3.save!
          # end
        else
          raise "ვერ ვაკეთებ მრავალაბონენტიანი განშლის გაუქმებას."
        end
      end
    end
  end

  def init_payment_id
    last = Network::NewCustomerApplication.last
    self.payment_id = last.present? ? last.payment_id + 1 : 1
  end

  def upcase_number
    self.number = self.number.upcase if self.number.present?
    true
  end

  def prepare_mobile
    self.mobile = KA::compact_mobile(self.mobile) if self.mobile.present?
    true
  end
end
