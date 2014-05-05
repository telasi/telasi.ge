# -*- encoding : utf-8 -*-
require 'rs'

class Customer::Registration
  include Mongoid::Document
  include Mongoid::Timestamps
  include Customer::Constants

  STATUS_START = 1
  STATUS_DOCS_REQUIRED = 2
  STATUS_COMPLETE = 3
  STATUS_CANCELED = 4

  belongs_to :user, class_name: 'Sys::User'
  has_many :documents, class_name: 'Customer::Document', inverse_of: 'registration'
  has_many :messages, class_name: 'Sys::SmsMessage', as: 'messageable'
  field :status, type: Integer, default: STATUS_START
  field :custkey, type: Integer
  field :rs_tin, type: String
  field :rs_name, type: String
  field :address, type: String
  field :address_code, type: String
  field :category, type: String, default: CAT_PERSONAL
  field :ownership, type: String, default: OWN_OWNER
  field :need_factura, type: Mongoid::Boolean, default: false
  field :change_data, type: Mongoid::Boolean, default: true
  field :bank_code, type: String
  field :bank_account, type: String
  field :receive_sms, type: Mongoid::Boolean, default: true

  # validates :custkey, uniqueness: { message: I18n.t('models.customer_registration.errors.customer_duplicate'), scope: :user_id }
  validates :rs_tin, presence: { message: I18n.t('models.customer_registration.errors.tin_required') }
  validates :address, presence: { message: I18n.t('models.customer_registration.errors.address_required') }
  validates :address_code, presence: { message: I18n.t('models.customer_registration.errors.address_code_required') }
  validate  :validate_rs_name
  before_create :on_before_create
  before_save :on_save

  def self.status_name(stat)
    case stat
    when STATUS_START then I18n.t('models.customer_registration.status_names.start')
    when STATUS_DOCS_REQUIRED then I18n.t('models.customer_registration.status_names.docs_required')
    when STATUS_COMPLETE then I18n.t('models.customer_registration.status_names.complete')
    when STATUS_CANCELED then I18n.t('models.customer_registration.status_names.canceled')
    else '?' end
  end

  def self.status_icon(stat)
    case stat
    when STATUS_START then '/icons/clock.png'
    when STATUS_DOCS_REQUIRED then '/icons/exclamation-red.png'
    when STATUS_COMPLETE then '/icons/tick.png'
    when STATUS_CANCELED then '/icons/cross.png'
    else nil end
  end

  def self.status_sms(stat)
    case stat
    when STATUS_START then I18n.t('models.customer_registration.status_sms.start')
    when STATUS_DOCS_REQUIRED then I18n.t('models.customer_registration.status_sms.docs_required')
    when STATUS_COMPLETE then I18n.t('models.customer_registration.status_sms.complete')
    when STATUS_CANCELED then I18n.t('models.customer_registration.status_sms.canceled')
    else '?' end
  end

  def transitions
    case self.status
    when STATUS_START then [STATUS_DOCS_REQUIRED,STATUS_COMPLETE,STATUS_CANCELED]
    when STATUS_DOCS_REQUIRED then [STATUS_START,STATUS_CANCELED]
    else [] end
  end

  def customer; @customer ||= Billing::Customer.find(self.custkey) end
  def status_name; Customer::Registration.status_name(self.status) end
  def status_icon; Customer::Registration.status_icon(self.status) end
  def confirmed?; self.status == STATUS_COMPLETE end
  def not_denied_documents; self.documents.where(denied: false) end
  def denied_documents; self.documents.where(denied: true) end
  def all_docs_uploaded?; self.not_denied_documents.select{|x| not x.has_file? }.empty? end
  def show_docs_required_warning?; [STATUS_START,STATUS_DOCS_REQUIRED].include?(self.status) and not self.all_docs_uploaded? end
  def show_resend_warning?; self.status == STATUS_DOCS_REQUIRED and self.all_docs_uploaded? end
  def allow_edit?; not [STATUS_COMPLETE,STATUS_CANCELED].include?(self.status) end
  def personal?; self.category==CAT_PERSONAL end
  def not_personal?; self.category==CAT_NOT_PERSONAL end
  def suggested_name; self.rs_name.split(' ').reverse.join(' ') end

  def generate_docs(only_required=false)
    doctypes = Customer::DocumentType.where(category: self.category, ownership: self.ownership)
    doctypes = doctypes.where(required:true) if only_required
    doctypes.each do |type|
      if self.not_denied_documents.where(document_type: type).count == 0
        Customer::Document.new(document_type: type, registration: self, complete: false, denied: false).save
      end
    end
  end

  def sync_with_billing(type)
    customer=self.customer
    case type
    when 'custname' then customer.custname=self.suggested_name.to_geo
    when 'taxid' then customer.taxid=self.rs_tin
    when 'email' then customer.email=self.user.email
    when 'phone'
      if customer.tel.blank?
        customer.tel=self.user.mobile
      elsif customer.tel and not customer.tel.include?(self.user.mobile)
        customer.tel="#{customer.tel}; #{self.user.mobile}"
      end
    end
    customer.save if customer.changed?
  end

## DEBT SMS

  def self.send_sms_for_today
    Customer::Registration.where(status:STATUS_COMPLETE).each do |reg|
      last_notification=Customer::DebtNotification.where(registration:reg).desc(:_id).first
      deadline=reg.customer.cut_deadline
      if deadline and deadline>Date.today and (last_notification.blank? or deadline!=last_notification.for_deadline)
        reg.send_debt_sms
      end
    end
  end

  def send_debt_sms
    cust=self.customer
    notification=Customer::DebtNotification.create(registration:self,for_deadline:cust.cut_deadline)
    msg=Sys::SmsMessage.create(message:cust.balance_sms, mobile:self.user.mobile, messageable:notification)
    msg.send_sms!(lat:true)
  end

  private

  def validate_rs_name
    if self.rs_tin.present?
      self.rs_name = RS.get_name_from_tin(RS::TELASI_SU.merge(tin: self.rs_tin))
      errors.add(:rs_tin, I18n.t('models.customer_registration.errors.tin_illegal')) if self.rs_name.blank?
    end
  end

  def on_before_create; self.generate_docs(true) end

  def on_save
    if self.category==CAT_PERSONAL
      self.bank_code=self.bank_account=nil
      self.need_factura=false
    end
    true
  end
end
