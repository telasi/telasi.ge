# -*- encoding : utf-8 -*-
class Billing::NewCustomerFactura< ActiveRecord::Base
  self.table_name  = 'bs.new_customer_factura'
  self.primary_key = :id

  ADVANCE = 0
  CONFIRMED = 1
  CORRECTING1 = 2
  CORRECTING2 = 3

  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey
  belongs_to :item, class_name: 'Billing::Item', foreign_key: :itemkey
end
