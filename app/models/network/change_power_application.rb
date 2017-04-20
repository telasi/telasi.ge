# -*- encoding : utf-8 -*-
class Network::ChangePowerApplication
  STATUS_DEFAULT    = 0
  STATUS_SENT       = 1
  STATUS_CANCELED   = 2
  STATUS_CONFIRMED  = 3
  STATUS_COMPLETE   = 4
  STATUS_IN_BS      = 5
  STATUSES = [ STATUS_DEFAULT, STATUS_SENT, STATUS_CANCELED, STATUS_CONFIRMED, STATUS_COMPLETE, STATUS_IN_BS ]
  STATUSES_REPORT_BY_STATUS = [ STATUS_SENT, STATUS_CANCELED, STATUS_CONFIRMED, STATUS_COMPLETE, STATUS_IN_BS ]
  VOLTAGE_220 = '220'
  VOLTAGE_380 = '380'
  VOLTAGE_610 = '6/10'
  VOLTAGE_35110 = '35/110'
  TYPE_CHANGE_POWER  = 0
  TYPE_CHANGE_SOURCE = 1
  TYPE_SPLIT         = 2
  TYPE_RESERVATION   = 3
  TYPE_TEMP_BUILD    = 4
  TYPE_ABONIREBA     = 5
  TYPES = [ TYPE_CHANGE_POWER, TYPE_CHANGE_SOURCE, TYPE_SPLIT, TYPE_RESERVATION, TYPE_TEMP_BUILD, TYPE_ABONIREBA ]

  include Mongoid::Document
  include Mongoid::Timestamps
  include Network::RsName
  include Sys::VatPayer
  include Network::ApplicationBase
  include Network::BsBase

  belongs_to :user, class_name: 'Sys::User'
  field :number,    type: String
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
  field :status, type: Integer, default: STATUS_DEFAULT
  field :type,   type: Integer, default: TYPE_CHANGE_POWER
  field :work_by_telasi, type: Mongoid::Boolean, default: true
  # old voltage
  field :old_voltage, type: String
  field :old_power,   type: Float
  field :voltage,     type: String
  field :power,       type: Float
  field :amount,      type: Float, default: 0
  field :minus_amount,type: Float, default: 0
  field :customer_id, type: Integer
  # dates
  field :send_date, type: Date
  field :start_date, type: Date
  field :real_end_date, type: Date
  field :end_date, type: Date
  field :note, type: String
  field :oqmi, type: String
  field :proeqti, type: String
  # factura fields
  field :factura_id, type: Integer
  field :factura_seria, type: String
  field :factura_number, type: Integer
  field :need_factura, type: Mongoid::Boolean, default: true
  # sign field
  field :signed, type: Mongoid::Boolean, default: false
  # field :show_tin_on_print, type: Mongoid::Boolean, default: true
  field :zero_charge, type: Mongoid::Boolean, default: false
  # relations
  has_many :messages, class_name: 'Sys::SmsMessage', as: 'messageable'
  has_many :files, class_name: 'Sys::File', inverse_of: 'mountable'
  has_many :requests, class_name: 'Network::RequestItem', as: 'source'
  belongs_to :stage, class_name: 'Network::Stage'

  # validates :number, presence: { message: I18n.t('models.network_change_power_application.errors.number_required') }
  validates :user, presence: { message: 'user required' }
  validates :rs_tin, presence: { message: I18n.t('models.network_change_power_application.errors.tin_required') }
  validates :mobile, presence: { message: I18n.t('models.network_change_power_application.errors.mobile_required') }
  validates :address, presence: { message: I18n.t('models.network_change_power_application.errors.address_required') }
  # validates :address_code, presence: { message: I18n.t('models.network_change_power_application.errors.address_code_required') }
  # validates :bank_code, presence: { message: I18n.t('models.network_change_power_application.errors.bank_code_required') }
  # validates :bank_account, presence: { message: I18n.t('models.network_change_power_application.errors.bank_account_required') }
  # validates :old_voltage, presence: { message: 'required!' }
  # validates :old_power, numericality: { message: I18n.t('models.network_change_power_application.errors.illegal_power') }
  validates :voltage, presence: { message: 'required!' }
  validates :power, numericality: { message: I18n.t('models.network_change_power_application.errors.illegal_power') }
  #validates :customer, presence: { message: 'აარჩიეთ აბონენტი' }

  validate :validate_rs_name, :validate_number
  before_save :status_manager, :calculate_total_cost

  def self.correct_number?(type, number)
    if type == TYPE_CHANGE_POWER
      not not (/^(1CNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_CHANGE_SOURCE
      not not (/^(TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_SPLIT
      not not (/^(1TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif [TYPE_RESERVATION, TYPE_TEMP_BUILD, TYPE_ABONIREBA].include?(type)
      not not (/^(TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    else
      false
    end
  end

  def unit
    if [VOLTAGE_610, VOLTAGE_35110].include?(self.voltage) then I18n.t('models.network_change_power_application.unit_kvolt')
    else I18n.t('models.network_change_power_application.unit_volt') end
  end
  def old_unit
    if [VOLTAGE_610, VOLTAGE_35110].include?(self.voltage) then I18n.t('models.network_change_power_application.unit_kvolt')
    else I18n.t('models.network_change_power_application.unit_volt') end
  end
  def bank_name; Bank.bank_name(self.bank_code) if self.bank_code.present? end
  def customer; Billing::Customer.find(self.customer_id) if self.customer_id.present? end
  def self.status_name(status); I18n.t("models.network_change_power_application.status_#{status}") end
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
  def self.type_name(type); I18n.t("models.network_change_power_application.type_#{type}") end
  def status_name; Network::NewCustomerApplication.status_name(self.status) end
  def status_icon; Network::NewCustomerApplication.status_icon(self.status) end
  def type_name; Network::ChangePowerApplication.type_name(self.type) end

  def transitions
    case self.status
    when STATUS_DEFAULT   then [ STATUS_SENT, STATUS_CANCELED ]
    when STATUS_SENT      then [ STATUS_CONFIRMED, STATUS_CANCELED ]
    when STATUS_CONFIRMED then [ STATUS_COMPLETE, STATUS_CANCELED ]
    when STATUS_COMPLETE  then [ STATUS_CANCELED ]
    when STATUS_CANCELED  then [ ]
    else [ ]
    end
  end

  def update_last_request
    req = self.requests.last
    self.stage = req.present? ? req.stage : nil
    self.save
  end

  def can_change_amount?; self.type != TYPE_CHANGE_POWER end

  def factura_sent?; not self.factura_seria.blank? end
  def can_send_factura?; self.need_factura and [STATUS_SENT, STATUS_CONFIRMED, STATUS_COMPLETE, STATUS_IN_BS].include?(self.status) and not self.factura_sent? and (self.amount || 0) > 0 end
  def can_send_to_bs?; self.status == STATUS_COMPLETE and (self.amount||0) > 0 end

  def send_to_bs!
    # customer
    customer = self.customer

    # general parameters
    item_date = self.end_date
    main_amount = self.amount

    # find zdeposit customer
    deposit_customer = Billing::NetworkCustomer.where(customer: customer).first
    if deposit_customer.blank?
      Billing::NetworkCustomer.from_bs_customer(customer)
      deposit_customer = Billing::NetworkCustomer.where(customer: customer).first
    end
    raise "სადეპოზიტო აბონენტი ვერ მოიძებნა: #{customer.accnumb}!" if deposit_customer.blank?

    if main_amount > 0
      # sending to billing
      Billing::Item.transaction do
        bs_item = Billing::Item.new(billoperkey: 1001, acckey: customer.accounts.first.acckey,
          custkey: customer.custkey, perskey: 1, signkey: 1, itemdate: item_date, reading: 0,
          kwt: 0, amount: main_amount, enterdate: Time.now, itemcatkey: 0)
        bs_item.save!
        network_item = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id,
          amount: main_amount, operkey: 1001, enterdate: Time.now, operdate: item_date, perskey: 1)
        network_item.save!
      end

      # update application status
      self.status = STATUS_IN_BS
      self.save
    end
  end

  private

  def status_manager
    if self.status_changed?
      case self.status
      when STATUS_DEFAULT   then self.send_date = nil
      when STATUS_SENT      then self.send_date  = Date.today
      when STATUS_CONFIRMED then self.start_date = Date.today
      when STATUS_COMPLETE  then self.end_date   = Date.today
      end
    end
  end

  def calculate_total_cost
    unless self.can_change_amount?
      if self.zero_charge
        self.amount = 0
      else
        tariff_old = Network::NewCustomerTariff.tariff_for(self.old_voltage, self.old_power, self.start_date)
        tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power, self.start_date)
        if tariff_old.price_gel > tariff.price_gel
          self.amount = 0
        elsif tariff_old == tariff
          if self.old_power == self.power
            self.amount = 0
          else
            per_kwh = tariff.price_gel * 1.0 / tariff.power_to
            self.amount = (per_kwh * (self.power - self.old_power)).round(2) - minus_amount.abs
          end
        else
          self.amount = tariff.price_gel - tariff_old.price_gel - minus_amount.abs
        end
      end

      # fixing amount
      self.amount = 0 if self.amount < 0
    end
  end

  def validate_number
    if self.status != STATUS_DEFAULT and self.number.blank?
      self.errors.add(:number, 'ჩაწერეთ ნომერი')
    elsif self.number.present?
      self.errors.add(:number, 'არასწორი ფორმატი!') unless Network::ChangePowerApplication.correct_number?(self.type, self.number)
    end
  end
end
