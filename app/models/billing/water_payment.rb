# -*- encoding : utf-8 -*-
class Billing::WaterPayment < ActiveRecord::Base
  # self.table_name  = 'paymentsadmin.payments_gwp'
  # self.primary_key = :opayment_id
  self.table_name  = 'call.ruby_water_payments_didube'
  self.primary_key = :paykey
  belongs_to :customer, class_name: 'Bs::Customer', foreign_key: :custkey
end
