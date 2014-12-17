# -*- encoding : utf-8 -*-
class Customer::DebtNotification
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :registration, class_name: 'Customer::Registration'
  has_one :message, class_name: 'Sys::SmsMessage', as: 'messageable'
  field :for_deadline, type: Date
  field :custkey, type: Integer

  index({custkey: 1})
  index({registration_id: 1})

  def self.should_notify(deadline, last_notification)
    return (
      deadline and
      deadline > Date.today and
      (last_notification.blank? or deadline != last_notification.for_deadline)
    )
  end

  def self.send_notifications

    # TODO: update existing Customer::DebtNotification to contain custkey 

    # 1. first send registered customers

    Customer::Registration.sms_candidates.each do |reg|
      last_notification = Customer::DebtNotification.where(custkey:reg.custkey).desc(:_id).first
      deadline = reg.customer.cut_deadline
      reg.send_debt_sms if Customer::DebtNotification.should_notify(deadline, last_notification)
    end

    # 2. send mainstream customers

    # TODO:

  end
end
