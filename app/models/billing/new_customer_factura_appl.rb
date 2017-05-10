# -*- encoding : utf-8 -*-
class Billing::NewCustomerFacturaAppl< ActiveRecord::Base
  self.table_name  = 'bs.new_customer_factura_appl'
  self.primary_key = :id
  self.sequence_name = 'BS.new_cust_fact_appl_seq'

  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey
  belongs_to :item, class_name: 'Billing::Item', foreign_key: :itemkey
  belongs_to :appl, class_name: 'Billing::NewCustomerFactura', foreign_key: :factura_id
end
