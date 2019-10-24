# -*- encoding : utf-8 -*-
class Billing::OutageJournalDet < ActiveRecord::Base
  self.table_name  = 'bacho.outage_journal_det'
  self.primary_key = :id
end
