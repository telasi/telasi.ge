# -*- encoding : utf-8 -*-
class Billing::Payment < ActiveRecord::Base
  self.establish_connection 		:bs
  
  self.table_name  = 'payments.payment'
  self.primary_key = :paykey
  self.sequence_name = 'payments.payments_seq'
  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey
end
