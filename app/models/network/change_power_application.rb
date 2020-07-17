# -*- encoding : utf-8 -*-
class Network::ChangePowerApplication < Network::BaseClass
  SERVICE_METER_SETUP    = 9
  SERVICE_CHANGE_POWER   = 10
  SERVICE_MICRO_POWER    = 11
  SERVICE_TECH_CONDITION = 12
  SERVICES = [ SERVICE_METER_SETUP, SERVICE_CHANGE_POWER, SERVICE_MICRO_POWER, SERVICE_TECH_CONDITION ]

  TYPE_CHANGE_POWER  = 0
  TYPE_CHANGE_SOURCE = 1
  TYPE_SPLIT         = 2
  TYPE_RESERVATION   = 3
  TYPE_TEMP_BUILD    = 4
  TYPE_ABONIREBA     = 5
  TYPE_MICROPOWER    = 6
  TYPE_SAME_PACK     = 7
  TYPE_HIGH_VOLTAGE  = 8
  TYPE_SUB_CUSTOMER  = 9
  TYPE_MICRO_OTHER_PACK = 10
  TYPE_MICRO_SAME_PACK = 11
  TYPES = [ TYPE_CHANGE_POWER, TYPE_CHANGE_SOURCE, TYPE_SPLIT, TYPE_RESERVATION, TYPE_TEMP_BUILD, TYPE_ABONIREBA,
            TYPE_SAME_PACK, TYPE_HIGH_VOLTAGE, TYPE_SUB_CUSTOMER, TYPE_MICROPOWER, TYPE_MICRO_OTHER_PACK, TYPE_MICRO_SAME_PACK ]

  SERVICE_TECH_CONDITION_DAYS = 10

  GNERC_SIGNATURE_FILE = 'ChangePower_'
  GNERC_RES_FILE = 'res'
  GNERC_ACT_FILE = 'act'
  GNERC_DEF_FILE = 'def'
  GNERC_REFAB_FILE = 'refab'
  GNERC_CADAST_FILE = 'cadastral'

  include Mongoid::Document
  include Mongoid::Timestamps
  include Network::RsName
  include Sys::VatPayer
  include Network::ApplicationBase
  include Network::BsBase
  include Network::Factura
  include Network::CalculationUtils
  include Network::ChangePowerGnerc
  #include Network::Postpone

  belongs_to :user, class_name: 'Sys::User'
  belongs_to :tariff_multiplier, class_name: 'Network::TariffMultiplier'
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
  field :service, type: Integer, default: SERVICE_CHANGE_POWER
  field :type,   type: Integer, default: TYPE_CHANGE_POWER
  field :work_by_telasi, type: Mongoid::Boolean, default: true
  # old voltage
  field :old_voltage, type: String
  field :old_power,   type: Float
  field :voltage,     type: String
  field :power,       type: Float
  field :amount,      type: Float, default: 0
  field :minus_amount,type: Float, default: 0
  field :days,        type: Integer, default: 0
  field :customer_type_id, type: Integer
  field :customer_id, type: Integer
  field :real_customer_id, type: Integer
  field :mtnumb, type: String

  field :penalty1,    type: Float, default: 0

  # dates
  field :send_date, type: Date
  field :start_date, type: Date
  # წარმოებაში მიღების თარიღი
  field :production_date, type: Date
  # წარმოებაში მიღების თარიღი რეალური
  field :production_enter_date, type: Date
  field :real_end_date, type: Date
  field :plan_end_date, type: Date
  field :end_date, type: Date
  # cancelation_date არის გაუქმების თარიღი
  field :cancelation_date, type: Date
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

  field :duration, type: Integer, default: DURATION_STANDARD
  field :abonent_amount, type: Integer, default: ABONENT_AMOUNT_DEFAULT
  field :total_overdue_days, type: Integer

  # since Nov,2014: use business days!
  field :use_business_days, type: Mongoid::Boolean, default: false

  field :substation, type: String
  field :micro_power_source, type: Integer

  field :tech_condition_cns, type: String

  field :changing_technical_condition, type: Mongoid::Boolean, default: false
  field :gnerc_id, type: String
  field :sms_response, type: BSON::ObjectId

  # relations
  has_many :messages, class_name: 'Sys::SmsMessage', as: 'messageable'
  has_many :files, class_name: 'Sys::File', inverse_of: 'mountable'
  has_many :requests, class_name: 'Network::RequestItem', as: 'source'
  has_many :overdue, class_name: 'Network::OverdueItem', as: 'source'
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
  before_save :status_manager, :calculate_total_cost, :update_customer, :calculate_plan_end_date
  before_create :set_user_business_days

  def self.correct_number?(type, number)
    if type == TYPE_CHANGE_POWER
      not not (/^(1CNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_CHANGE_SOURCE
      not not ((/^(TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) ||
              (/^(TTCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number))
    elsif type == TYPE_SPLIT
      not not (/^(1TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif [TYPE_RESERVATION, TYPE_TEMP_BUILD, TYPE_ABONIREBA].include?(type)
      not not ((/^(TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) ||
              (/^(TTCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number))
    elsif type == TYPE_MICROPOWER
      not not (/^(RCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_SAME_PACK
      not not (/^(2CNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_HIGH_VOLTAGE
      not not (/^(HCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_SUB_CUSTOMER
      not not ((/^(TCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number) ||
              (/^(TTCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number))
    elsif type == TYPE_MICRO_OTHER_PACK
      not not (/^(1RCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    elsif type == TYPE_MICRO_SAME_PACK
      not not (/^(2RCNS)-[0-9]{2}\/[0-9]{4}\/[0-9]{2}$/i =~ number)
    else
      false
    end
  end

  def use_business_days=(use_business_days)
    write_attribute(:use_business_days, use_business_days)
  end

  def use_business_days
    true
  end

  def unit
    if [VOLTAGE_610, VOLTAGE_35110].include?(self.voltage) then I18n.t('models.network_change_power_application.unit_kvolt')
    else I18n.t('models.network_change_power_application.unit_volt') end
  end
  def old_unit
    if [VOLTAGE_610, VOLTAGE_35110].include?(self.voltage) then I18n.t('models.network_change_power_application.unit_kvolt')
    else I18n.t('models.network_change_power_application.unit_volt') end
  end
  def real_customer; Billing::Customer.find(self.real_customer_id) if self.real_customer_id.present? end
  def self.type_name(type); I18n.t("models.network_change_power_application.type_#{type}") end
  def self.service_name(type); I18n.t("models.network_change_power_application.service_#{type}") end
  def status_name; Network::NewCustomerApplication.status_name(self.status) end
  def status_icon; Network::NewCustomerApplication.status_icon(self.status) end
  def type_name; Network::ChangePowerApplication.type_name(self.type) end
  def service_name; Network::ChangePowerApplication.service_name(self.service) end

  def self.type_by_service(service)
    case service
      when SERVICE_METER_SETUP    then [ TYPE_CHANGE_SOURCE, 
                                         TYPE_SPLIT, 
                                         TYPE_RESERVATION, 
                                         TYPE_TEMP_BUILD, 
                                         TYPE_ABONIREBA, 
                                         TYPE_SUB_CUSTOMER ]
      when SERVICE_CHANGE_POWER   then [ TYPE_CHANGE_POWER, TYPE_SAME_PACK ]
      when SERVICE_MICRO_POWER    then [ TYPE_MICROPOWER, TYPE_MICRO_OTHER_PACK, TYPE_MICRO_SAME_PACK ]
      when SERVICE_TECH_CONDITION then [ TYPE_CHANGE_SOURCE, TYPE_SPLIT, TYPE_RESERVATION, TYPE_TEMP_BUILD, TYPE_ABONIREBA, TYPE_SUB_CUSTOMER ]
    end.map{ |x| [ x, type_name(x) ] }
  end

  def prepayment_percent; self.billing_prepayment_total / self.amount * 100 rescue 0 end

  def facturas
    array = registered_facturas.where('factura_id <> ?',self.factura_id.to_i).dup
    if self.factura_id.present?
      array << Billing::NewCustomerFactura.new(factura_id: self.factura_id, factura_seria: self.factura_seria, factura_number: self.factura_number, amount: self.amount)
    end
    array
  end

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

  def can_change_amount?; not [TYPE_CHANGE_POWER, TYPE_SAME_PACK].include?(self.type) end
  def apply_multiplier?; [TYPE_CHANGE_POWER, TYPE_MICROPOWER, TYPE_MICRO_OTHER_PACK, TYPE_MICRO_SAME_PACK].include?(self.type) end
  # def apply_duration?; [TYPE_CHANGE_POWER, TYPE_MICROPOWER, TYPE_MICRO_OTHER_PACK, TYPE_MICRO_SAME_PACK].include?(self.type) end
  def apply_duration?; self.start_date.present? && ( self.start_date >= Date.new(2020,1,1) ) end

  def prepayment_factura_sent?
    prepayment_facturas.present?
  end

  def prepayment_enough?
    return false unless self.amount
    ( billing_prepayment_to_factured_sum + billing_items_raw_to_factured_sum ) > 0 and 
    ( billing_prepayment_to_factured_sum + billing_items_raw_to_factured_sum >= self.amount / 2 )
  end

  def can_send_prepayment_factura?
    # return false
    return false unless self.need_factura
    return false unless self.status == STATUS_CONFIRMED
    # return false if has_new_cust_charge?
    return false if self.factura_sent?
    if billing_prepayment_factura.present? or billing_items_raw_to_factured.present?
      return true if ( billing_prepayment_to_factured.present? or billing_items_raw_to_factured.present? )
    else
      return true if prepayment_enough?
    end 

    return false
  end

  def factura_sent?; not self.factura_seria.blank? end
  def can_send_factura?; self.need_factura and [STATUS_SENT, STATUS_COMPLETE, STATUS_IN_BS].include?(self.status) and not self.factura_sent? and (self.amount || 0) > 0 end
  def can_send_to_bs?; self.status == STATUS_COMPLETE and (self.amount||0) > 0 end

  def send_to_bs!
    checks_for_gnerc_2

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
          amount: main_amount, operkey: 1001, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: real_end_date)
        network_item.save!

        first_stage = -self.penalty_first_stage
        #if first_stage < 0
        #  bs_item1 = Billing::Item.new(billoperkey: 1006, acckey: customer.accounts.first.acckey, custkey: customer.custkey,
        #    perskey: 1, signkey: 1, itemdate: item_date, reading: 0, kwt: 0, amount: first_stage,
        #    enterdate: Time.now, itemcatkey: 0)
        #  bs_item1.save!
        #  network_item1 = Billing::NetworkItem.new(zdepozit_cust_id: deposit_customer.zdepozit_cust_id, amount: first_stage,
        #    operkey: 1006, enterdate: Time.now, operdate: item_date, perskey: 1, cns: self.number, montage_date: end_date)
        #  network_item1.save!
        #end

      end

      # update application status
      self.status = STATUS_IN_BS
      self.save

      send_to_gnerc(2)
    end
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
    factura = RS::Factura.new(date: factura_date, seller_id: RS::TELASI_PAYER_ID)
    good_name = "ქსელზე მიერთების პაკეტის ღირებულების ავანსი #{self.number}"
    amount = item.amount
    raise 'თანხა უნდა იყოს > 0' unless amount > 0
    raise 'ფაქტურის გაგზავნა ვერ ხერხდება!' unless RS.save_factura_advance(factura, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, buyer_tin: self.rs_tin))
    vat = self.pays_non_zero_vat? ? amount * (1 - 1.0 / 1.18) : 0
    factura_item = RS::FacturaItem.new(factura: factura,
      good: good_name, unit: 'მომსახურეობა', amount: amount, vat: vat,
      quantity: 0)
    RS.save_factura_item(factura_item, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID))
    if RS.send_factura(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))
      factura = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))

       Billing::NewCustomerFactura.transaction do 
          billing_factura = Billing::NewCustomerFactura.new(application: 'CP',
                                                            cns: self.number, 
                                                            factura_id: factura.id, 
                                                            factura_seria: factura.seria.to_geo, 
                                                            factura_number: factura.number,
                                                            category: Billing::NewCustomerFactura::ADVANCE,
                                                            amount: amount, period: factura_date)
          billing_factura.save

          billing_factura_appl = Billing::NewCustomerFacturaAppl.new(itemkey: item.itemkey, 
                                                                       custkey: self.customer.custkey, 
                                                                       application: 'CP',
                                                                       cns: self.number, 
                                                                       factura_id: billing_factura.id,
                                                                       factura_date: Time.now)
          billing_factura_appl.save
        end

    end
  end

  def send_factura!(factura, amount)
    Billing::NewCustomerFactura.transaction do 
      billing_factura = Billing::NewCustomerFactura.new(application: 'CP',
                                                        cns: self.number, 
                                                        factura_id: factura.id, 
                                                        factura_seria: factura.seria.to_geo, 
                                                        factura_number: factura.number,
                                                        category: Billing::NewCustomerFactura::CONFIRMED,
                                                        amount: amount, period: self.start_date)
      billing_factura.save

      billing_factura_appl = Billing::NewCustomerFacturaAppl.new(custkey: self.customer.custkey, 
                                                                 application: 'CP',
                                                                 cns: self.number, 
                                                                 start_date: self.start_date,
                                                                 plan_end_date: self.plan_end_date,
                                                                 factura_id: billing_factura.id,
                                                                 factura_date: Time.now)
      billing_factura_appl.save
    end
  end

  def message_to_gnerc(message)
    self.sms_response = message.id
    self.save

    # docflow = Gnerc::Docflow4.where(letter_number: self.number).first
    # return if docflow.blank?
    
    # docflow.update_attributes!(company_answer: message.message, phone: message.mobile, confirm: 1)
  end

  def first_sms
    message = Sys::SmsMessage.new(message: "თქვენი განაცხადი #{self.number} დარეგისტრირდა და მიღებულია განსახილველად #{self.production_date}. ელ. ჟურნალში რეგისტრაციის N #{self.gnerc_id}")
    message.messageable = self
    message.mobile = self.mobile
    message.send_sms!(lat: true) if message.save
  end

  private

  def status_manager
    if self.status_changed?
      case self.status
      when STATUS_DEFAULT   then self.send_date = nil
      when STATUS_SENT      then self.send_date = self.start_date = Date.today
      when STATUS_CONFIRMED then 
        raise 'აარჩიეთ რეალური აბონენტი' if [SERVICE_CHANGE_POWER, SERVICE_MICRO_POWER].include?(self.service) && self.real_customer_id.blank?
        raise "ატვირთეთ cadastral ფაილი ან შეიყვანეთ საკადასტრო მისამართი" unless check_cadastral

        self.production_date = get_fifth_day
        self.production_enter_date = Date.today

        send_to_gnerc(1)
      when STATUS_COMPLETE  then self.end_date   = Date.today
      when STATUS_CANCELED  then
        raise "ატვირთეთ def ფაილი" unless check_file_uploaded
        self.cancelation_date = Date.today
        send_to_gnerc(2)
      end
    end
  end

  def calculate_total_cost
    calculate_region
    case self.service
      when SERVICE_METER_SETUP                           then calculate_meter
      when SERVICE_TECH_CONDITION                        then calculate_tech
      when SERVICE_CHANGE_POWER                          then calculate_change_power
      when SERVICE_MICRO_POWER                           then calculate_micro
    end
  end

  def calculate_change_power
    unless self.can_change_amount?

      if self.zero_charge
        self.amount = 0
      else
        tariff_old = Network::NewCustomerTariff.tariff_for(self.old_voltage, self.old_power, self.start_date)
        tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power, self.start_date)
        multiplier = 1 
        multiplier = self.tariff_multiplier.multiplier if self.tariff_multiplier
        if tariff_old.price_gel > tariff.price_gel
          self.amount = 0
        elsif tariff_old == tariff
          if self.old_power == self.power
            self.amount = 0
          else
            per_kwh = tariff.price_gel * 1.0 / tariff.power_to
            self.amount = (per_kwh * (self.power - self.old_power)).round(2) - self.minus_amount
            self.amount = (per_kwh * (self.power - self.old_power) * multiplier ).round(2) - self.minus_amount if apply_multiplier?
          end
        else
          self.amount = tariff.price_gel - tariff_old.price_gel - self.minus_amount
          self.amount = ( tariff.price_gel - tariff_old.price_gel ) * multiplier - self.minus_amount if apply_multiplier?
        end
      end

      # fixing amount
      self.amount = 0 if self.amount < 0
    end

    if apply_duration?
      tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power, self.start_date)
      if tariff.present?
        self.days = tariff.days(self)
        if self.use_business_days
          self.plan_end_date = (self.days - 1).business_days.after( self.send_date )
        else
          self.plan_end_date = self.send_date + self.days - 1
        end
      end
    end
  end

  def calculate_micro
    unless self.can_change_amount?

      if self.zero_charge
        self.amount = 0
      else
        tariff_old = Network::MicroTariff.tariff_for(self.old_voltage, self.old_power, self.start_date)
        tariff = Network::MicroTariff.tariff_for(self.voltage, self.power, self.start_date)
        multiplier = 1 
        multiplier = self.tariff_multiplier.multiplier if self.tariff_multiplier
        if tariff_old.price_gel > tariff.price_gel
          self.amount = 0
        elsif tariff_old == tariff
          if self.old_power == self.power
            self.amount = 0
          else
            per_kwh = tariff.price_gel * 1.0 / tariff.power_to
            self.amount = (per_kwh * (self.power - self.old_power)).round(2) - self.minus_amount
            self.amount = (per_kwh * (self.power - self.old_power) * multiplier ).round(2) - self.minus_amount if apply_multiplier?
          end
        else
          self.amount = tariff.price_gel - tariff_old.price_gel - self.minus_amount
          self.amount = ( tariff.price_gel - tariff_old.price_gel ) * multiplier - self.minus_amount if apply_multiplier?
        end
      end

      # fixing amount
      self.amount = 0 if self.amount < 0
    end

    if apply_duration?
      tariff = Network::MicroTariff.tariff_for(self.voltage, self.power, self.start_date)
      if tariff.present?
        self.days = tariff.days(self)
        if self.use_business_days
          self.plan_end_date = (self.days - 1).business_days.after( self.send_date )
        else
          self.plan_end_date = self.send_date + self.days - 1
        end
      end
    end
  end

  def calculate_meter
    unless self.can_change_amount?

      if self.zero_charge
        self.amount = 0
      else
        tariff_old = Network::MeterSetupTariff.tariff_for(self.old_voltage, self.old_power, self.start_date)
        tariff = Network::MeterSetupTariff.tariff_for(self.voltage, self.power, self.start_date)
        multiplier = 1 
        multiplier = self.tariff_multiplier.multiplier if self.tariff_multiplier
        if tariff_old.price_gel > tariff.price_gel
          self.amount = 0
        elsif tariff_old == tariff
          if self.old_power == self.power
            self.amount = 0
          else
            per_kwh = tariff.price_gel * 1.0 / tariff.power_to
            self.amount = (per_kwh * (self.power - self.old_power)).round(2) - self.minus_amount
            self.amount = (per_kwh * (self.power - self.old_power) * multiplier ).round(2) - self.minus_amount if apply_multiplier?
          end
        else
          self.amount = tariff.price_gel - tariff_old.price_gel - self.minus_amount
          self.amount = ( tariff.price_gel - tariff_old.price_gel ) * multiplier - self.minus_amount if apply_multiplier?
        end
      end

      # fixing amount
      self.amount = 0 if self.amount < 0
    end

    if apply_duration?
      tariff = Network::MeterSetupTariff.tariff_for(self.voltage, self.power, self.start_date)
      if tariff.present?
        self.days = tariff.days(self)
        if self.use_business_days
          self.plan_end_date = (self.days - 1).business_days.after( self.send_date )
        else
          self.plan_end_date = self.send_date + self.days - 1
        end
      end
    end
  end

  def calculate_tech
    unless self.can_change_amount?

      if self.zero_charge
        self.amount = 0
      else
        tariff_old = Network::MeterSetupTariff.tariff_for(self.old_voltage, self.old_power, self.start_date)
        tariff = Network::MeterSetupTariff.tariff_for(self.voltage, self.power, self.start_date)
        multiplier = 1 
        multiplier = self.tariff_multiplier.multiplier if self.tariff_multiplier
        if tariff_old.price_gel > tariff.price_gel
          self.amount = 0
        elsif tariff_old == tariff
          if self.old_power == self.power
            self.amount = 0
          else
            per_kwh = tariff.price_gel * 1.0 / tariff.power_to
            self.amount = (per_kwh * (self.power - self.old_power)).round(2) - self.minus_amount
            self.amount = (per_kwh * (self.power - self.old_power) * multiplier ).round(2) - self.minus_amount if apply_multiplier?
          end
        else
          self.amount = tariff.price_gel - tariff_old.price_gel - self.minus_amount
          self.amount = ( tariff.price_gel - tariff_old.price_gel ) * multiplier - self.minus_amount if apply_multiplier?
        end
      end

      # fixing amount
      self.amount = 0 if self.amount < 0
    end

    if apply_duration?
      tariff = Network::MeterSetupTariff.tariff_for(self.voltage, self.power, self.start_date)
      if tariff.present?
        self.days = tariff.days(self)
        self.days = SERVICE_TECH_CONDITION_DAYS if self.days == 0
        if self.use_business_days
          self.plan_end_date = (self.days - 1).business_days.after( self.send_date )
        else
          self.plan_end_date = self.send_date + self.days - 1
        end
      end
    end
  end

  def set_user_business_days
    self.use_business_days = true
  end

  def update_customer
    if self.changes["customer_id"].present?
      oldcustomer = self.changes["customer_id"][0]
      newcustomer = self.changes["customer_id"][1]

      oldcust = Billing::Customer.find(oldcustomer) if oldcustomer.present?
      oldcust.update_attribute(:custsert, nil) if oldcust.present?

      newcust = Billing::Customer.find(newcustomer) if newcustomer.present?
      newcust.update_attribute(:custsert, self.number) if newcust.present?
    end 
  end

  def validate_number
    if self.status != STATUS_DEFAULT and self.number.blank?
      self.errors.add(:number, 'ჩაწერეთ ნომერი')
    elsif self.number.present?
      self.errors.add(:number, 'არასწორი ფორმატი!') unless Network::ChangePowerApplication.correct_number?(self.type, self.number)
    elsif self.service == SERVICE_METER_SETUP && self.tech_condition_cns.blank?
      self.errors.add(:tech_condition_cns, 'ჩაწერეთ ტექპირობის ნომერი')
    end
  end

  def send_to_gnerc_old(stage)
    if stage == 1
      # file = self.files.select{ |x| x.file.filename[0..11] == GNERC_SIGNATURE_FILE }.first
      # if file.present?
      #   content = File.read(file.file.file.file)
      #   content = Base64.encode64(content)

      #   letter_category = get_letter_category

      #   parameters = { letter_number:       self.number,
      #                  abonent:             self.rs_name,
      #                  abonent_number:      self.real_customer.accnumb,
      #                  abonent_type:        self.real_customer.abonent_type, 
      #                  abonent_address:     self.address,
      #                  appeal_date:         self.start_date,
      #                  attach_4_1:          content,
      #                  attach_4_1_filename: file.file.filename,
      #                  letter_category:     letter_category
      #                }

      #   GnercWorkerOld.perform_async("appeal", 4, parameters)
      # end
    else 
      file = self.files.select{ |x| x.file.filename[0..2] == GNERC_ACT_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
        parameters = { letter_number:       self.number,
                       attach_4_2:          content,
                       attach_4_2_filename: file.file.filename,
                       affirmative:         1
                     }
      else
        file = self.files.select{ |x| x.file.filename[0..2] == GNERC_DEF_FILE }.first
        if file.present?
          content = File.read(file.file.file.file)
          content = Base64.encode64(content)
          parameters = { letter_number:       self.number,
                         attach_4_2:          content,
                         attach_4_2_filename: file.file.filename,
                         affirmative:         0
                       }
        else
          file = self.files.select{ |x| x.file.filename[0..4] == GNERC_REFAB_FILE }.first
          content = File.read(file.file.file.file)
          content = Base64.encode64(content)
          parameters = { letter_number:       self.number,
                         attach_4_2:          content,
                         attach_4_2_filename: file.file.filename,
                         affirmative:         0
                       }
        end
      end
      GnercWorkerOld.perform_async("answer", 4, parameters)
    end
  end

  def get_letter_category
    case self.type
    when TYPE_CHANGE_POWER then 25
    when TYPE_CHANGE_SOURCE then 9
    when TYPE_SPLIT then 27
    when TYPE_RESERVATION then 5
    when TYPE_TEMP_BUILD then 26
    when TYPE_ABONIREBA then 23
    when TYPE_MICROPOWER then 23
    when TYPE_SAME_PACK then 25
    when TYPE_HIGH_VOLTAGE then 23
    when TYPE_SUB_CUSTOMER then 28
    else 31
    end
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
