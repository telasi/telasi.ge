# -*- encoding : utf-8 -*-
class Billing::NetworkCustomer < ActiveRecord::Base
  self.table_name  = 'bs.zdepozit_cust_qs'
  self.primary_key = 'zdepozit_cust_id'

  belongs_to :customer, class_name: 'Billing::Customer', foreign_key: :custkey

  def self.from_bs_customer(customer)
    Billing::NetworkCustomer.new(
      customer: customer,
      custname: customer.custname,
      taxid_or_personalid: customer.taxid,
      status: 0,
      perskey: 1,
      is_printed: 0,
      debet_type: 1
    ).save
  end
end
