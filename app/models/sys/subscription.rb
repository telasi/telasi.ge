# -*- encoding : utf-8 -*-
class Sys::Subscription
  include Mongoid::Document
  include Mongoid::Timestamps

  HASH_PREFIX = 'subscribe'
  HASH_SUFFIX = 'confirm'

  field :email,  type: String
  field :active,       type: Mongoid::Boolean, default: true
  field :company_news, type: Mongoid::Boolean, default: true
  field :procurement_news, type: Mongoid::Boolean, default: true
  field :outage_news, type: Mongoid::Boolean, default: true
  field :locale, type: String, default: 'ka'
  field :confirmed,    type: Mongoid::Boolean, default: false

  def generate_hash; Digest::MD5.hexdigest("#{HASH_PREFIX}#{email}#{HASH_SUFFIX}") end 

  validates :email,
    uniqueness: { message: I18n.t('models.sys_subscription.errors.duplicated_email') },
    presence: { message: I18n.t('models.sys_subscription.errors.empty_email') },
    email: { format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create, message: I18n.t('models.sys_user.errors.illegal_email') } }
  index({ email: 1 }, { unique: true })

  def user; Sys::User.where(email: self.email).first end

  def belong_to_type(headline_type)
    case headline_type
    when 'power'   then self.outage_news
    when 'news'    then self.company_news
    when 'tenders' then self.procurement_news
    end
  end
end
