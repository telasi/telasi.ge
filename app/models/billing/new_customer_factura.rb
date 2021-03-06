# -*- encoding : utf-8 -*-
class Billing::NewCustomerFactura< ActiveRecord::Base
  self.table_name  = 'bs.new_customer_factura'
  self.primary_key = :id

  ADVANCE = 0
  CONFIRMED = 1
  CORRECTING1 = 2
  CORRECTING2 = 3

  FACTURA_NAMES = {
      0 => 'საავანსო',
      1 => 'დარიცხვა',
      2 => 'კორექცია I',
      3 => 'კორექცია II' 
  }

  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey
  has_one :appl, class_name: 'Billing::NewCustomerFacturaAppl', foreign_key: :factura_id

  def category_name; FACTURA_NAMES[self.category] end
end
