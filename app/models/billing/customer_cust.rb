# -*- encoding : utf-8 -*-
class Billing::CustomerCust< ActiveRecord::Base
  self.table_name  = 'bs.act_customer_cust'
  self.primary_key = :id

  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey
end
