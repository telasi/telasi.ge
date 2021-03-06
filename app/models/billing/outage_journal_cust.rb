# -*- encoding : utf-8 -*-
class Billing::OutageJournalCust < ActiveRecord::Base
  self.table_name  = 'bacho.outage_journal_cust'
  self.primary_key = :custkey_customer

  belongs_to :detail, class_name: 'Billing::OutageJournalDet', foreign_key: :journal_det_id
  belongs_to :journal, class_name: 'Billing::OutageJournal', foreign_key: :off_id, primary_key: :off_id

  scope :accepted, ->() { joins(:journal).where("OFF_DTIME BETWEEN TO_DATE('2020-01-01', 'YYYY-MM-DD') AND SYSDATE AND IS_GIS IN ('ki', 'ara') AND GADAIDO <> 1") }
  scope :open, ->() { joins(:detail).where('outage_journal_det.ON_TIME is NULL') }
end
