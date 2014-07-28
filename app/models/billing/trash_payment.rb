# -*- encoding : utf-8 -*-
class Billing::TrashPayment < ActiveRecord::Base
  self.establish_connection :bs
  
  self.table_name  = 'payments.trashpayment'
  self.primary_key = :paykey
  self.sequence_name = 'payments.trashpayments_seq'
  self.set_integer_columns :status
  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey
end
