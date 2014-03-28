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

  # validates :custkey, uniqueness: { message: I18n.t('models.customer_registration.errors.customer_duplicate'), scope: :user_id }
  validates :rs_tin, presence: { message: I18n.t('models.customer_registration.errors.tin_required') }
  validates :address, presence: { message: I18n.t('models.customer_registration.errors.address_required') }
  validates :address_code, presence: { message: I18n.t('models.customer_registration.errors.address_code_required') }
  validate  :validate_rs_name

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

  def generate_docs
    Customer::DocumentType.where(category: self.category, ownership: self.ownership).each do |type|
      if self.documents.where(document_type: type, denied: false).count == 0
        Customer::Document.new(document_type: type, registration: self, complete: false, denied: false).save
      end
    end
  end

  private

  def validate_rs_name
    if self.rs_tin.present?
      self.rs_name = RS.get_name_from_tin(RS::TELASI_SU.merge(tin: self.rs_tin))
      errors.add(:rs_tin, I18n.t('models.customer_registration.errors.tin_illegal')) if self.rs_name.blank?
    end
  end
end
