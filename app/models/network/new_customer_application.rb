# -*- encoding : utf-8 -*-
class Network::NewCustomerApplication < Network::BaseClass
  TYPE_INDIVIDUAL    = 1
  TYPE_MULTI_ABONENT = 2
  TYPE_MICRO         = 3
  TYPE_MULTI_MICRO   = 4
  TYPE_SEPARATED     = 5
  TYPES = [ TYPE_INDIVIDUAL, TYPE_MULTI_ABONENT, TYPE_MICRO, TYPE_MULTI_MICRO, TYPE_SEPARATED ]

  GNERC_SIGNATURE_FILE = 'NewCustomer_'
  GNERC_ACT_FILE = 'act'
  GNERC_DEF_FILE = 'def'
  GNERC_REFAB_FILE = 'refab'
  GNERC_CADAST_FILE = 'cadastral'

  CUSTOMER_AMOUNT_PRICE_MULTI_START_DATE = Date.new(2019,8,13)
  CUSTOMER_AMOUNT_PRICE_MULTI = 100

  include Mongoid::Document
  include Mongoid::Timestamps
  include Network::RsName
  include Sys::VatPayer
  include Network::CalculationUtils
  include Network::ApplicationBase
  include Network::BsBase
  include Network::Factura
  include Network::NewCustomerGnerc

  belongs_to :user, class_name: 'Sys::User'
  belongs_to :tariff, class_name: 'Network::NewCustomerTariff'
  belongs_to :micro_tariff, class_name: 'Network::MicroTariff'
  belongs_to :tariff_multiplier, class_name: 'Network::TariffMultiplier'
  field :online, type: Mongoid::Boolean, default: false # ონლაინ არის შევსებული?
  field :number,    type: String
  field :payment_id, type: Integer
  field :rs_tin,       type: String
  field :rs_foreigner, type: Mongoid::Boolean, default: false
  field :rs_name,      type: String
  field :mobile,    type: String
  field :email,     type: String
  field :address,   type: String
  field :work_address, type: String
  field :address_code, type: String
  field :bank_code,    type: String
  field :bank_account, type: String
  field :status,     type: Integer, default: STATUS_DEFAULT
  field :type,   type: Integer, default: TYPE_INDIVIDUAL
  field :personal_use, type: Mongoid::Boolean, default: true
  field :notes, type: String
  field :oqmi, type: String
  field :proeqti, type: String
  # გამოთვლის დეტალები და ბილინგთან კავშირი
  field :need_resolution,  type: Mongoid::Boolean, default: true
  field :duration, type: Integer, default: DURATION_STANDARD
  field :abonent_amount, type: Integer, default: ABONENT_AMOUNT_DEFAULT
  field :total_overdue_days, type: Integer

  field :voltage,     type: String
  field :power,       type: Float
  field :amount,      type: Float, default: 0
  field :std_amount,      type: Float, default: 0
  field :micro_amount,      type: Float, default: 0
  field :days,        type: Integer, default: 0
  field :customer_id, type: Integer
  field :customer_type_id, type: Integer
  field :penalty1,    type: Float, default: 0
  field :penalty2,    type: Float, default: 0
  field :penalty3,    type: Float, default: 0
  ### დღეების ანგარიში ###
  # send_date, არის თარიღი, როდესაც მოხდა განცხადების თელასში გამოგზავნა
  field :send_date, type: Date
  # start_date, არის თარიღი, როდესაც თელასმა განხცადება წამოებაში მიიღო
  field :start_date, type: Date
  # წარმოებაში მიღების თარიღი
  field :production_date, type: Date
  # წარმოებაში მიღების თარიღი რეალური
  field :production_enter_date, type: Date
  # plan_end_date / end_date, არის თარიღი (გეგმიური / რეალური), როდესაც დასრულდება
  # ამ განცხადებით გათვალიწინებული ყველა სამუშაო
  field :plan_end_date, type: Date
  field :end_date, type: Date
  # cancelation_date არის გაუქმების თარიღი
  field :cancelation_date, type: Date
  # factura fields
  field :factura_id, type: Integer
  field :factura_seria, type: String
  field :factura_number, type: Integer
  field :need_factura, type: Mongoid::Boolean, default: false
  field :show_tin_on_print, type: Mongoid::Boolean, default: false
  # aviso id
  field :aviso_id, type: Integer

  # confirmation flags
  field :doc_id,        type: Mongoid::Boolean, default: false
  field :doc_ownership, type: Mongoid::Boolean, default: false
  field :doc_project,   type: Mongoid::Boolean, default: false
  field :doc_payment,   type: Mongoid::Boolean, default: false
  field :confirm_correctness,  type: Mongoid::Boolean, default: false

  # digital signature
  field :signed, type: Mongoid::Boolean, default: false

  # since Nov,2014: use business days!
  field :use_business_days, type: Mongoid::Boolean, default: false

  # micropower
  field :micro, type: Mongoid::Boolean, default: false
  field :micro_voltage,     type: String
  field :micro_power,       type: Float
  field :micro_power_source, type: Integer

  field :substation, type: String

  field :gnerc_id, type: String
  field :sms_response, type: BSON::ObjectId

  embeds_many :items, class_name: 'Network::NewCustomerItem', inverse_of: :application
  has_many :files, class_name: 'Sys::File', as: 'mountable'
  has_many :messages, class_name: 'Sys::SmsMessage', as: 'messageable', :order => 'created_at ASC'
  has_many :requests, class_name: 'Network::RequestItem', as: 'source'
  has_many :overdue, class_name: 'Network::OverdueItem', as: 'source'
  belongs_to :stage, class_name: 'Network::Stage'

  validates :user, presence: { message: I18n.t('models.network_new_customer_application.errors.user_required') }
  validates :rs_tin, presence: { message: I18n.t('models.network_new_customer_application.errors.tin_required') }
  validates :mobile, presence: { message: I18n.t('models.network_new_customer_application.errors.mobile_required') }
  # validates :email, presence: { message: I18n.t('models.network_new_customer_application.errors.email_required') }
  validates :address, presence: { message: I18n.t('models.network_new_customer_application.errors.address_required') }
  # validates :address_code, presence: { message: I18n.t('models.network_new_customer_application.errors.address_code_required') }
  # validates :bank_code, presence: { message: I18n.t('models.network_new_customer_application.errors.bank_code_required') }
  # validates :bank_account, presence: { message: I18n.t('models.network_new_customer_application.errors.bank_account_required') }
  validates :voltage, presence: { message: I18n.t('models.network_new_customer_application.errors.volt_required') }
  validates :power, numericality: { message: I18n.t('models.network_new_customer_item.errors.illegal_power') }
  validate :validate_rs_name, :validate_number, :validate_mobile
  before_save :status_manager, :calculate_total_cost, :upcase_number, :prepare_mobile, :calculate_plan_end_date
  before_create :init_payment_id, :set_user_business_days

  # Checking correctess of
  def self.correct_number?(micro, number)
    if micro
      not not (/^(MCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) 
    else
      not not ((/^(CNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) ||
              (/^(SCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) )
    end
  end

  def unit
    if self.voltage == '6/10' then I18n.t('models.network_new_customer_item.unit_kvolt')
    else I18n.t('models.network_new_customer_item.unit_volt') end
  end
  def effective_number; self.number.blank? ? self.payment_id : self.number end
  def can_send_to_item?; self.status == STATUS_COMPLETE end #and self.items.any? end
  def formatted_mobile; KA::format_mobile(self.mobile) if self.mobile.present? end
  def self.type_name(type); I18n.t("models.network_new_customer_application.type_#{type}") end
  def type_name; Network::NewCustomerApplication.type_name(self.type) end

  def editable_online?; self.status == STATUS_DEFAULT end
  def not_sent?; self.status == STATUS_DEFAULT end
  def docs_are_ok?; self.doc_payment and self.doc_ownership and self.doc_id end
  def can_send?; self.status == STATUS_DEFAULT and self.docs_are_ok? and self.confirm_correctness end
  def add_price_for_customer_amount?; self.abonent_amount > 1 && ( self.start_date || Date.today ) >= CUSTOMER_AMOUNT_PRICE_MULTI_START_DATE end
  def customer_amount_price; self.abonent_amount * Network::NewCustomerApplication::CUSTOMER_AMOUNT_PRICE_MULTI end
  def total_days; self.days + self.total_overdue_days || 0 end
  # def active_overdues; 

  def facturas
    array = registered_facturas.where('factura_id <> ?',self.factura_id.to_i).dup
    if self.factura_id.present?
      array << Billing::NewCustomerFactura.new(factura_id: self.factura_id, factura_seria: self.factura_seria, factura_number: self.factura_number, amount: effective_amount, category: Billing::NewCustomerFactura::CONFIRMED)
    end
    array
  end

  def prepayment_percent; self.billing_prepayment_total / self.amount * 100 rescue 0 end

  # შესაძლო სტატუსების ჩამონათვალი მიმდინარე სტატუსიდან.
  def transitions
    case self.status
    when STATUS_DEFAULT       then [ STATUS_SENT, STATUS_CANCELED ]
    when STATUS_SENT          then [ STATUS_DEFAULT, STATUS_CONFIRMED, STATUS_CANCELED ]
    when STATUS_CONFIRMED     then [ STATUS_COMPLETE, STATUS_CANCELED, STATUS_USER_DECLINED ]
    when STATUS_COMPLETE      then [ STATUS_CANCELED ]
    when STATUS_IN_BS         then [ STATUS_CANCELED ]
    when STATUS_CANCELED      then [ STATUS_DEFAULT, STATUS_SENT ]
    else [ ]
    end
  end

  def sync_customers!
    self.items.destroy_all
    if self.customer
      customers = Billing::CustomerRelation.new_customer_application_subcustomers(self.customer)
      customers.each do |customer|
        Network::NewCustomerItem.new(application: self, customer_id: customer.custkey).save
      end
    end
    calculate_distribution!
  end

  # ვალის/კომპენსაციის გადანაწილების დათვლა.
  def calculate_distribution!
    items = self.items
    distribute(items, self.remaining) do |item, part|
      item.amount = part
      item.save
    end
    distribute(items, self.penalty_third_stage) do |item, part|
      item.amount_compensation = part
      item.save
    end
  end

  # მეორე ეტაპის ჯარიმა.
  def penalty_second_stage
    if self.status != STATUS_CANCELED and self.send_date and self.start_date
      if real_days > 2 * days
        self.amount / 2
      else 0 end
    else 0 end
  end

  # მესამე ეტაპის ჯარიმა (კომპენსაცია).
  def penalty_third_stage
    if self.status != STATUS_CANCELED and self.send_date and self.start_date
      r_days = self.real_days
      if r_days > 2*days and days > 0
        ( (r_days - 2*days - 1).to_i/days )*self.amount/2
      else 0 end
    else 0 end
  end

  # ჯარიმის სრული ოდენობა.
  def total_penalty; self.penalty_first_stage + self.penalty_second_stage + self.penalty_third_stage end

  def penalty_first_corrected
    return 0 unless self.penalty1 > 0
    amount = self.amount || 0
    sum = ( self.billing_prepayment_factura_sum - ( amount / 2 ) ) 
    if sum < 0
      sum = 0
    end
    sum
  end

  def penalty_second_corrected
    return 0 unless self.penalty2 > 0
    amount = self.amount || 0
    factura_sum = self.billing_prepayment_factura_sum
    if factura_sum > ( amount / 2 )
      sum = amount / 2
    else 
      sum = factura_sum
    end
    sum
  end

  private

  def send_main_operations!(customer, deposit_customer, amount, item_date)
    # set customer exception status
    #customer.except = true
    #customer.save!
    account = customer.accounts.first
    # adding exception to 
    deposit_customer.exception_end_date = item_date + (self.personal_use ? 20 : 10)
    deposit_customer.save!
    # bs.item - charge operation
    bs_item = Billing::Item.new(billoperkey: 1000, acckey: account.acckey, custkey: customer.custkey,
      perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: amount,
      enterdate: Time.now, itemcatkey: 0)
    bs_item.save!
    network_item = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: amount,
      operkey: 1000, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: end_date)
    network_item.save!
    # I. bs.item - first stage penalty
    first_stage = -self.penalty_first_stage
    if first_stage < 0
      bs_item1 = Billing::Item.new(billoperkey: 1006, acckey: account.acckey, custkey: customer.custkey,
        perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: first_stage,
        enterdate: Time.now, itemcatkey: 0)
      bs_item1.save!
      network_item1 = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: first_stage,
        operkey: 1006, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: end_date)
      network_item1.save!
    end
    # II. bs.item - second stage penalty
    second_stage = -self.penalty_second_stage
    if second_stage < 0
      bs_item2 = Billing::Item.new(billoperkey: 1007, acckey: account.acckey, custkey: customer.custkey,
        perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: second_stage,
        enterdate: Time.now, itemcatkey: 0)
      bs_item2.save!
      network_item2 = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: second_stage,
        operkey: 1007, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: end_date)
      network_item2.save!
    end
    # III. bs.item - third stage penalty
    third_stage = -self.penalty_third_stage
    if third_stage < 0
      bs_item3 = Billing::Item.new(billoperkey: 1120, acckey: account.acckey, custkey: customer.custkey,
        perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: third_stage,
        enterdate: Time.now, itemcatkey: 0)
      bs_item3.save!
      # network_item3 = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: third_stage,
      #   operkey: 1120, enterdate: Time.now, operdate: item_date, perskey: 1)
      # network_item3.save!
    end
  end

  def get_deposit_customer
    cust=Billing::NetworkCustomer.where(customer: customer).first
    if cust.blank?
      Billing::NetworkCustomer.from_bs_customer(customer)
      cust=Billing::NetworkCustomer.where(customer: customer).first
    end
    cust
  end

  public

  def link_bs_customer!(param)
    self.customer_id = param[:customer_id]
    self.save!

    cust=Billing::Customer.find(param[:customer_id])
    cust.custsert = self.number
    cust.save!
  end

  def remove_bs_customer!
    cust=Billing::Customer.find(self.customer_id)
    cust.custsert = nil
    cust.save!

    self.customer_id = nil
    self.save!
  end

  # ბილინგში გაგზავნა.
  def send_to_bs!
    # don't resend an application the second time
    return if self.status==STATUS_IN_BS

    raise "ატვირთეთ act ფაილი" unless check_file_uploaded

    # sync customers
    self.sync_customers!

    # customer
    customer = self.customer

    # general parameters
    item_date = self.end_date
    main_amount = self.amount

    # find zdeposit customer
    deposit_customer = get_deposit_customer
    raise "სადეპოზიტო აბონენტი ვერ მოიძებნა: #{customer.accnumb}!" if deposit_customer.blank?

    # sending to billing
    Billing::Item.transaction do
      # make transactions on main account
      send_main_operations!(customer, deposit_customer, main_amount, item_date)

      if self.items.empty?
        # nothing todo here!
      else
        remaining = self.remaining
        compensation = self.penalty_third_stage
        # remove remaining amount from main account (if any) => 1008
        if remaining > 0
          bs_item = Billing::Item.new(billoperkey: 1008, acckey: customer.accounts.first.acckey, custkey: customer.custkey,
            perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: -remaining,
            enterdate: Time.now, itemcatkey: 0)
          bs_item.save!
          network_item = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: -remaining,
            operkey: 1008, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: end_date)
          network_item.save!
        end
        # remove compensation from main account (if any) => XXX: which operation???
        if compensation > 0
          bs_item = Billing::Item.new(billoperkey: 1120, acckey: customer.accounts.first.acckey, custkey: customer.custkey,
            perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: compensation,
            enterdate: Time.now, itemcatkey: 0)
          bs_item.save!
          network_item = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: compensation,
            operkey: 1120, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: end_date)
          network_item.save!
        end
        # distribute remaining amount on subcustomers => 1000
        # distribute compensation on subcustomers (if any) => 1120
        if remaining > 0 || compensation > 0
          self.items.each do |item|
            cust = item.customer
            acct = cust.accounts.first
            if item.amount > 0
              # XXX: operation?
              bs_item = Billing::Item.new(billoperkey: 1000, acckey: acct.acckey, custkey: cust.custkey,
                perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: item.amount,
                enterdate: Time.now, itemcatkey: 0)
              bs_item.save
            elsif item.amount_compensation > 0
              # XXX: operation?
              bs_item = Billing::Item.new(billoperkey: 1120, acckey: acct.acckey, custkey: cust.custkey,
                perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: -item.amount_compensation,
                enterdate: Time.now, itemcatkey: 0)
              bs_item.save
            end
          end
        end
      end
    end
    # update application status
    self.status = STATUS_IN_BS
    self.save

    send_to_gnerc(2)
  end

  def send_prepayment_facturas!(items)
    billing_items = Billing::Item.where(itemkey: items)

    if billing_items.to_a.sum(&:amount) < ( self.amount / 2 )
      raise 'არა საკმარისი თანხა' 
    end

    billing_items.each do |item|
      send_one_factura(item)
    end

  end

  def send_one_factura(item)
    factura_date = self.factura_date(item)
    good_name = "ქსელზე მიერთების პაკეტის ღირებულების ავანსი #{self.number}"

    factura = RS::Factura.new(date: factura_date, seller_id: RS::TELASI_PAYER_ID)
    amount = item.amount
    raise 'თანხა უნდა იყოს > 0' unless amount > 0
    raise 'ფაქტურის გაგზავნა ვერ ხერხდება!' unless RS.save_factura_advance(factura, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, buyer_tin: self.rs_tin))
    vat = self.pays_non_zero_vat? ? amount * (1 - 1.0 / 1.18) : 0
    factura_item = RS::FacturaItem.new(factura: factura, good: good_name, unit: 'მომსახურეობა', amount: amount, vat: vat, quantity: 0)
    RS.save_factura_item(factura_item, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID))

    if RS.send_factura(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))
      factura = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))

      Billing::NewCustomerFactura.transaction do 
        billing_factura = Billing::NewCustomerFactura.new(application: 'NC',
                                                          cns: self.number, 
                                                          factura_id: factura.id, 
                                                          factura_seria: factura.seria.to_geo, 
                                                          factura_number: factura.number,
                                                          category: Billing::NewCustomerFactura::ADVANCE,
                                                          amount: amount, period: factura_date)
        billing_factura.save

        billing_factura_appl = Billing::NewCustomerFacturaAppl.new(itemkey: item.itemkey, custkey: self.customer.custkey, 
                                                                   application: 'NC',
                                                                   cns: self.number, 
                                                                   start_date: self.start_date,
                                                                   plan_end_date: self.plan_end_date,
                                                                   factura_id: billing_factura.id,
                                                                   factura_date: Time.now)
        billing_factura_appl.save  
      end
    end
  end

  def send_factura!(factura, amount)
    Billing::NewCustomerFactura.transaction do 
      billing_factura = Billing::NewCustomerFactura.new(application: 'NC',
                                                        cns: self.number, 
                                                        factura_id: factura.id, 
                                                        factura_seria: factura.seria.to_geo, 
                                                        factura_number: factura.number,
                                                        category: Billing::NewCustomerFactura::CONFIRMED,
                                                        amount: amount, period: self.start_date)
      billing_factura.save

      billing_factura_appl = Billing::NewCustomerFacturaAppl.new(custkey: self.customer.custkey, 
                                                                 application: 'NC',
                                                                 cns: self.number, 
                                                                 start_date: self.start_date,
                                                                 plan_end_date: self.plan_end_date,
                                                                 factura_id: billing_factura.id,
                                                                 factura_date: Time.now)
      billing_factura_appl.save
    end
  end

  def prepayment_factura_sent?
    prepayment_facturas.present?
  end

  def prepayment_enough?
    ( billing_prepayment_to_factured_sum + billing_items_raw_to_factured_sum ) > 0 and
    ( billing_prepayment_to_factured_sum + billing_items_raw_to_factured_sum >= self.effective_amount / 2 )
  end

  # def prepayment_enough?
  #   billing_prepayment_chosen_to_factured_sum > 0 and
  #   ( billing_prepayment_chosen_to_factured_sum >= self.effective_amount / 2 )
  # end

  def can_send_prepayment_factura?
    return false unless self.status == STATUS_CONFIRMED
    return false if ( self.send_date < Network::PREPAYMENT_START_DATE )
    return false unless self.need_factura
    return false if self.factura_sent?
    # return false if has_new_cust_charge?

    if billing_prepayment_factura.present? or billing_items_raw_to_factured.present?
      return true if ( billing_prepayment_to_factured.present? or billing_items_raw_to_factured.present? )
    else
      return true if prepayment_enough?
    end 

    # if billing_prepayment_factura.present? or billing_items_raw_to_factured.present?
    #    return true if billing_prepayment_chosen_to_factured.present? 
    #  else
    #    return true if prepayment_enough?
    #  end 

    return false
  end

  def factura_sent?
    not self.factura_seria.blank?
  end

  def can_send_factura?
    self.need_factura and
    [ STATUS_COMPLETE, STATUS_IN_BS ].include?(self.status) and
    not self.factura_sent? and
    self.effective_amount > 0
  end

  def can_send_correcting1_factura?
    self.penalty1 > 0 and
    not self.can_send_correcting2_factura? and 
    self.registered_facturas.where(category: Billing::NewCustomerFactura::ADVANCE).present? and
    not self.registered_facturas.where(category: Billing::NewCustomerFactura::CORRECTING1).present?
  end

  def can_send_correcting2_factura?
    self.penalty2 > 0 and
    self.registered_facturas.where(category: Billing::NewCustomerFactura::ADVANCE).present? and
    not self.registered_facturas.where(category: Billing::NewCustomerFactura::CORRECTING2).present?
  end

  def update_last_request
    req = self.requests.last
    self.stage = req.present? ? req.stage : nil
    self.save
  end

  def number_required?
    if self.online then not [STATUS_DEFAULT, STATUS_SENT].include?(self.status)
    else not [STATUS_DEFAULT].include?(self.status) end
  end

  def message_to_gnerc(message)
    self.sms_response = message.id
    self.save
    newcust = Gnerc::Newcust.where(letter_number: self.number).first
    return if newcust.blank?
    
    newcust.update_attributes!(company_answer: message.message, phone: message.mobile, confirmation: 1)

    newcusttest = Gnerc::NewcustTest.where(letter_number: self.number).first
    return if newcusttest.blank?
    
    newcusttest.update_attributes!(sms_response: message.message)
  end

  def first_sms
    message = Sys::SmsMessage.new(message: "თქვენი განაცხადი #{self.number} დარეგისტრირდა და მიღებულია განსახილველად #{self.production_date}. ელ. ჟურნალში რეგისტრაციის N #{self.gnerc_id}")
    message.messageable = self
    message.mobile = self.mobile
    message.send_sms!(lat: true) if message.save
  end

  private

  def calculate_total_cost
    calculate_region
    tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power, self.start_date)
    if tariff
      if power > 0
        self.tariff = tariff
        self.amount = self.std_amount = tariff.price_gel
        self.days   = tariff.days(self)
        # if self.abonent_amount > 2
        #   self.amount = self.amount + self.abonent_amount * 100
        # end
        self.amount = self.std_amount = (self.amount / 1.18 * 100).round / 100.0 unless self.pays_non_zero_vat?
        self.penalty1 = self.penalty_first_stage
        self.penalty2 = self.penalty_second_stage
        self.penalty3 = self.penalty_third_stage
      end
    else
      if power > 0
        self.amount = self.std_amount = nil
        self.days = nil
        self.tariff = nil
      end
    end
    if self.micro
      micro_tariff = Network::MicroTariff.tariff_for(self.micro_voltage, self.micro_power, self.start_date)
      if micro_tariff
        self.micro_amount = micro_tariff.price_gel
        #self.micro_amount = micro_tariff.price_gel * self.tariff_multiplier.multiplier if self.tariff_multiplier
        self.micro_tariff = micro_tariff
      end
    else
      self.micro_amount = 0
    end
    self.amount = self.std_amount + self.micro_amount
    self.amount = self.std_amount * self.tariff_multiplier.multiplier + self.micro_amount if self.tariff_multiplier

    self.amount = self.amount + self.abonent_amount * 100 if self.add_price_for_customer_amount?
  end

  def validate_number
    if self.number_required? and self.number.blank?
      self.errors.add(:number, I18n.t('models.network_new_customer_application.errors.number_required'))
    elsif self.number.present?
      self.errors.add(:number, 'არასწორი ფორმატი!') unless Network::NewCustomerApplication.correct_number?(self.micro, self.number)
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
      when STATUS_SENT      then 
        self.send_date  = self.start_date = Date.today
      when STATUS_CONFIRMED then
        raise "ატვირთეთ cadastral ფაილი ან შეიყვანეთ საკადასტრო მისამართი" unless check_cadastral

        self.production_date = get_fifth_day
        self.production_enter_date = Date.today
        send_to_gnerc(1)
      when STATUS_COMPLETE  then 
        raise 'გამოიწერეთ საავანსო ფაქტურა' if check_advance_factura_needed
        self.end_date   = Date.today
      when STATUS_CANCELED  then
        raise "ატვირთეთ def ფაილი" unless check_file_uploaded

        self.cancelation_date = Date.today
        send_to_gnerc(2)
        revert_bs_operations_on_cancel
      when STATUS_USER_DECLINED then
        raise "ატვირთეთ refab ფაილი" unless check_file_uploaded

        self.cancelation_date = Date.today
        send_to_gnerc(2)
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
          network_customer = get_deposit_customer
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
          #   bs_item3 = Billing::Item.new(billoperkey: 1120, acckey: account.acckey, custkey: customer.custkey,
          #     perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: third_stage,
          #     enterdate: Time.now, itemcatkey: 0)
          #   bs_item3.save!
          #   network_item3 = Billing::NetworkItem.new(zdepozit_cust_id: network_customer.zdepozit_cust_id, amount: third_stage,
          #     operkey: 1120, enterdate: Time.now, operdate: item_date, perskey: 1)
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

  def set_user_business_days
    self.use_business_days = true
  end

  def upcase_number
    self.number = self.number.upcase if self.number.present?
    true
  end

  def prepare_mobile
    self.mobile = KA::compact_mobile(self.mobile) if self.mobile.present?
    true
  end

  # def send_to_gnerc(stage)
  #   send_gnerc(self)
  # end

  def check_advance_factura_needed
    return false unless self.status == STATUS_CONFIRMED
    return false if ( self.send_date < Network::PREPAYMENT_START_DATE )
    return false unless self.need_factura

    self.billing_prepayment_to_factured.present? or ( self.billing_prepayment_factura_sum < ( self.effective_amount / 2 ))
  end

  def check_cadastral
    return true if self.address_code.present?

    file = self.files.select{ |x| x.file.filename[0..2] == GNERC_CADAST_FILE }.first
    return file.present?
  end

  def check_file_uploaded
    actfile = self.files.select{ |x| x.file.filename[0..2] == GNERC_ACT_FILE }.first
    if actfile.blank?
      deffile = self.files.select{ |x| x.file.filename[0..2] == GNERC_DEF_FILE }.first
      if deffile.blank?
        reffile = self.files.select{ |x| x.file.filename[0..4] == GNERC_REFAB_FILE }.first
         if reffile.blank?
          return false
         end
      end
    end
    return true
  end

end
