# -*- encoding : utf-8 -*-
class Pay::Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user, class_name: 'Sys::User'              # მომხმარებელი
  #field :user,             type: String
  field :serviceid,        type: String                  # მერჩანტის უნიკალური კოდი
  field :merchant, 	       type: String					         # მერჩანტის უნიკალური კოდი
  field :ordercode,        type: Integer					       # მერჩანტის ტრანზაქციის უნიკალური კოდი
  field :amount, 	         type: Float  					       # თანხა
 # field :amount_tech,      type: Integer                 # თანხა თეტრებში
  field :currency,         type: String, default: 'GEL'  # ვალუტა GEL
  field :date,             type: DateTime                # თარიღი
  field :status,           type: String                  # სტატუსი
  field :instatus,         type: String                  # სტატუსი
  field :gstatus,          type: String                  # სტატუსი
  field :transactioncode,  type: String                  # ტრანზაქციის კოდი
  field :paymethod,        type: String                  # გადახდის არხის სახელი
  field :description,      type: String					         # ოპერაციის აღწერა
  field :clientname,       type: String					         # კლიენტის სახელი
  field :ispreauth,        type: Integer, default: 0     # პრეაცვოიზაცია
  field :postpage,         type: Integer, default: 0     # ????
  field :customdata,       type: String					         # დამატებითი მონაცემები
  field :lng,              type: String					         # ენა
  field :testmode,         type: Integer 				         # სატესტო რეჟიმი
  field :check,            type: String	 				         # საკონტროლო კოდი
  field :check_returned,   type: String                  # საკონტროლო კოდი
  field :check_callback,   type: String                  # საკონტროლო კოდი
  field :check_response,   type: String                  # საკონტროლო კოდი
  field :successurl,       type: String					         # წარმატებით დასრულებისას დებრუნების მისამართი
  field :errorurl,         type: String					         # შეცდომისას დასრულებისას დებრუნების მისამართი
  field :cancelurl,        type: String					         # შეწყვეტისას დასრულებისას დებრუნების მისამართი
  field :callbackurl,      type: String                  # გადახდის დადასტურების მისამართი
  field :itemN_name,       type: String					         # საქონლის ჩამონათვალი, დასახელება
  field :itemN_price,      type: String					         # საქონლის ჩამონათვალი, ფასი
  field :resultcode,       type: Integer
  field :resultdesc,       type: String
  field :resultdata,       type: String

  validates :merchant, presence: { message: 'ჩაწერეთ მერჩანტი' }
  validates :ordercode, presence: { message: 'ჩაწერეთ შეკვეთის კოდი' }
  validates :amount, numericality: { greater_than: 0, message: 'მნიშვნელობა უნდა იყოს 0-ზე მეტი' }

  validates :currency, presence: { message: 'currency not defined' }
  validates :lng, presence: { message: 'lng not defined' }
  validates :testmode, presence: { message: 'testmode not defined' }
  validates :check, presence: { message: 'check not defined' }

  STATUS_COMPLETED = 'COMPLETED'
  STATUS_CANCELED  = 'CANCELED'
  STATUS_ERROR     = 'ERROR'

  INSTATUS_OK = 'OK'
  INSTATUS_RET_CHECK_ERROR = 'RET_CHECK_ERROR'
  INSTATUS_CAL_CHECK_ERROR = 'RET_CALLB_ERROR'

  GSTATUS_OK = 'OK'
  GSTATUS_SENT = 'SENT'
  GSTATUS_ERROR = 'ERROR'

  def amount_tech; (self.amount * 100).round end

  def get_current_password(merchant)
   Payge::PAY_SERVICES.find{ |h| h[:Merchant] == merchant }[:Password]
  end

  def check_text(step)
    merchant = 'TEST'
    password = 'hn*8SksyoPPheXJ81VDn'
    case step
     when Payge::STEP_SEND # გადახდების გვერდზე გადასვლა
        [
          #PAYGE_PASSWORD,
          #TELASI_MERCHANT,
          get_current_password(self.merchant),
          self.merchant,
          self.ordercode,
          self.amount_tech,
          self.currency,
          self.description,
          self.clientname,
          self.customdata,
          self.lng,
          self.testmode,
          self.ispreauth,
          self.postpage
         ].join
     when Payge::STEP_RETURNED # მერჩანტის გვერდზე დაბრუნება
        [
          self.status,
          self.transactioncode,
          self.date.strftime("%Y%m%d%H%M%S"),
          self.amount_tech,
          self.currency,
          self.ordercode,
          self.paymethod,
          self.customdata,
          self.testmode,
          get_current_password(self.merchant),
         ].join
     when Payge::STEP_CALLBACK # PAY სისტემიდან შეტყობინების გამოგზავნა
        [
          self.status,
          self.transactioncode,
          self.amount_tech,
          self.currency,
          self.ordercode,
          self.paymethod,
          self.customdata,
          self.testmode,
          get_current_password(self.merchant),
         ].join
     when Payge::STEP_RESPONSE # PAY სისტემის შეტყობინებაზე პასუხი
        [
          self.resultcode,
          self.resultdesc,
          self.transactioncode,
          get_current_password(self.merchant),
         ].join
    end
  end

  def prepare_for_step(step)
      text = check_text(step)
      self.check = Digest::SHA256.hexdigest(text).upcase
  end
end