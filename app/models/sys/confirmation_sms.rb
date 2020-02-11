# -*- encoding : utf-8 -*-
class Sys::ConfirmationSms
  include Mongoid::Document
  include Mongoid::Timestamps

  EXPIRATION_MINUTES = 60

  before_save :fill_expiration

  field :email,       type: String
  field :code,        type: String
  field :expiring_at, type: Date
  
  index({ email: 1 }, { unique: false })
  index({ expiring_at: 1 }, { unique: false })

  private 

  def fill_expiration
    self.expiring_at = Time.now + EXPIRATION_MINUTES.minutes
  end
end
