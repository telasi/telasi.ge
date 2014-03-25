# -*- encoding : utf-8 -*-
require 'rs'

class Customer::Registration
  include Mongoid::Document
  include Mongoid::Timestamps

  CAT_PERSONAL = 'personal'
  CAT_NOT_PERSONAL = 'not-personal'
  OWN_OWNER = 'owner'
  OWN_RENT  = 'rent'

  belongs_to :user, class_name: 'Sys::User'
  field :custkey, type: Integer

  field :category, type: String, default: CAT_PERSONAL
  field :ownership, type: String, default: OWN_OWNER

  field :rs_tin, type: String
  field :rs_name, type: String
  field :address, type: String
  field :address_code, type: String

  # validates :custkey, uniqueness: { message: I18n.t('models.customer_registration.errors.customer_duplicate'), scope: :user_id }
  validates :rs_tin, presence: { message: I18n.t('models.customer_registration.errors.tin_required') }
  validates :address, presence: { message: I18n.t('models.customer_registration.errors.address_required') }
  validates :address_code, presence: { message: I18n.t('models.customer_registration.errors.address_code_required') }
  validate  :validate_rs_name

  def customer; @customer ||= Billing::Customer.find(self.custkey) end

  private

  def validate_rs_name
    if self.rs_tin.present?
      self.rs_name = RS.get_name_from_tin(RS::TELASI_SU.merge(tin: self.rs_tin))
      errors.add(:rs_tin, I18n.t('models.customer_registration.errors.tin_illegal')) if self.rs_name.blank?
    end
  end
end
