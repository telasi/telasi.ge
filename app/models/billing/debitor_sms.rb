# -*- encoding : utf-8 -*-
class Billing::DebitorSms < ActiveRecord::Base
  self.establish_connection :bs

  self.table_name  = 'dimitri.zcust_sms'
  self.set_integer_columns :sent

  def self.send_sms!
    Billing::DebitorSms.connection.execute('begin dimitri.debitors_pack.prepare_sms_for_today; commit; end;')
    if Magti::SEND
      Billing::DebitorSms.where(sent: 0).each do |sms|
        Magti.send_sms(sms.mobile.strip, sms.smstext)
        sms.sent = 1
        sms.save
      end
    end
  end
end
