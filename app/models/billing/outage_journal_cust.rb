# -*- encoding : utf-8 -*-
class Billing::OutageJournalCust < ActiveRecord::Base
  self.table_name  = 'bacho.outage_journal_cust'
  self.primary_key = 'custkey_customer'

  has_one :detail, class_name: 'Billing::OutageJournalDet', foreign_key: :journal_det_id
end
