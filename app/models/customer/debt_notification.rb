# -*- encoding : utf-8 -*-
class Customer::DebtNotification
  include Mongoid::Document
  include Mongoid::Timestamps

  ON_NEW_CHARGE      = 'on-new-charge'
  ON_BEFORE_DEADLINE = 'on-before-deadline'

  belongs_to :registration, class_name: 'Customer::Registration'
  has_one    :message, class_name: 'Sys::SmsMessage', as: 'messageable'
  field      :for_deadline, type: Date
  field      :custkey, type: Integer
  field      :event, type: String, default: ON_NEW_CHARGE

  index({ custkey: 1 })
  index({ registration_id: 1 })

  def self.should_notify(deadline, last_notification)
    deadline && deadline > Date.today && ( last_notification.blank? || deadline != last_notification.for_deadline )
  end

  def self.send_notifications
    notify_registered_customers
    notify_mainstream_customers
  end

  def self.notify_registered_customers
    Customer::Registration.sms_candidates.each do |reg|
      send_balance_sms(reg.customer, reg)
      send_deadline_sms(reg.customer, reg)
    end
  end

  def self.notify_mainstream_customers
    Billing::Customer.sms_candidates.each do |cust|
      send_balance_sms(cust)
      send_deadline_sms(cust)
    end
  end

  def self.send_balance_sms(customer, registration = nil)
    mobile_number = registration ? registration.user.mobile : customer.fax.strip
    if mobile_number.length == 9
      event = ON_NEW_CHARGE
      last_notification = self.where(custkey: customer.custkey, event: event).desc(:_id).first
      deadline = customer.cut_deadline
      if should_notify(deadline, last_notification)
        notification = Customer::DebtNotification.create({
          registration: registration,
          for_deadline: deadline,
          custkey: customer.custkey,
          event: event
        })
        msg = Sys::SmsMessage.create(message: customer.balance_sms, mobile: mobile_number, messageable: notification)
        msg.send_sms!(lat: true)
      end
    end
  end

  def self.send_deadline_sms(customer, registration = nil)
    mobile_number = registration ? registration.user.mobile : customer.fax.strip
    if mobile_number.length == 9
      event = ON_BEFORE_DEADLINE
      last_notification = self.where(custkey: customer.custkey, event: event).desc(:_id).first
      deadline = customer.cut_deadline
      if deadline == ( Date.today + 1 ) && should_notify(deadline, last_notification)
        text = customer.deadline_sms
        if text.present?
          notification = Customer::DebtNotification.create({
            registration: registration,
            for_deadline: deadline,
            custkey: customer.custkey,
            event: event
          })
          msg = Sys::SmsMessage.create(message: text, mobile: mobile_number, messageable: notification)
          msg.send_sms!(lat: true)
        end
      end
    end
  end
end
