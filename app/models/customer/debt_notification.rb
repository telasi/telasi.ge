# -*- encoding : utf-8 -*-
class Customer::DebtNotification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :registration, class_name: 'Customer::Registration'
  has_one :message, class_name: 'Sys::SmsMessage', as: 'messageable'
  field :for_deadline, type: Date
end
