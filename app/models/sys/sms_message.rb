# -*- encoding : utf-8 -*-
class Sys::SmsMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :messageable, polymorphic: true
  field :mobile, type: String
  field :message, type: String
  validates :message, presence: { message: 'ჩაწერეთ შინაარსი.' }

  index(messageable_id: 1, messageable__type: 1)

  def send_sms!(opts = {})
    if Magti::SEND
      msg = self.message
      msg = msg.to_lat if opts[:lat]
      Magti.send_sms(self.mobile, msg)

      #bacho 
      smsg = Sys::SentMessage.new
      smsg.company='MAGTI'
      smsg.receiver_mobile = '995' + self.mobile.to_s
      smsg.text = msg
      smsg.status='S'
      smsg.sent_at=Time.now
      smsg.sender_user='MyTelasiGe'
      smsg.save
      #
    end
  end
end
