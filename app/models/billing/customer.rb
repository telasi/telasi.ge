# -*- encoding : utf-8 -*-
class Billing::Customer < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  ACTIVE = 0
  INACTIVE = 1
  CLOSED = 2

  self.table_name  = 'bs.customer'
  self.primary_key = :custkey

  belongs_to :address,      class_name: 'Billing::Address',       foreign_key: :premisekey
  belongs_to :send_address, class_name: 'Billing::Address',       foreign_key: :sendkey
  has_one  :trash_customer, class_name: 'Billing::TrashCustomer', foreign_key: :custkey
  has_one  :water_customer, class_name: 'Billing::WaterCustomer', foreign_key: :custkey
  has_many :water_items,    -> { order 'year, month' }, class_name: 'Billing::WaterItem', foreign_key: :custkey
  has_many :item_bills,     -> { order 'itemkey' },     class_name: 'Billing::ItemBill',  foreign_key: :custkey
  has_many :accounts,       class_name: 'Billing::Account',       foreign_key: :custkey
  has_many :customer_custs, class_name: 'Billing::CustomerCust',  foreign_key: :custkey
  has_one  :note,           class_name: 'Billing::Note',          foreign_key: :notekey
  belongs_to :category,     class_name: 'Billing::Custcateg',     foreign_key: :custcatkey
  belongs_to :activity,     class_name: 'Billing::Custcateg',     foreign_key: :activity

  def region; self.address.region end
  def water_balance; self.water_customer.new_balance rescue 0 end
  def current_water_balance; self.water_customer.curr_charge rescue 0 end
  def trash_balance; self.trash_customer.balance rescue 0 end
  def last_bill_date; self.item_bills.last.billdate end
  def last_bill_number; self.item_bills.last.billnumber end
  def cut_deadline; self.item_bills.last.lastday end

  def pre_payment
    Billing::Payment.where('paydate>? AND custkey=? AND status=1',Date.today-7,self.custkey).inject(0) do |sum,payment|
      sum+=payment.amount
    end
  end

  def pre_payment_date
    p=Billing::Payment.where('paydate>? AND custkey=? AND status=1',Date.today-7,self.custkey).order('paykey desc').first
    p.paydate if p
  end

  def pre_trash_payment
    Billing::TrashPayment.where('paydate>? AND custkey=? AND status=1',Date.today-7,self.custkey).inject(0) do |sum,payment|
      sum+=payment.amount
    end
  end

  def pre_trash_payment_date
    p=Billing::TrashPayment.where('paydate>? AND custkey=? AND status=1',Date.today-7,self.custkey).order('paykey desc').first
    p.paydate if p
  end

  def pre_water_payment
    Billing::WaterPayment.where('paydate>? AND custkey=? AND status=1',Date.today-7,self.custkey).inject(0) do |sum,payment|
      sum+=payment.amount
    end
  end

  def pre_water_payment_date
    p=Billing::WaterPayment.where('paydate>? AND custkey=? AND status=1', Date.today-7, self.custkey).order('paykey desc').first
    p.paydate if p
  end

  def status_name
    case self.statuskey
    when ACTIVE then I18n.t('models.bs.customer.statuses.active')
    when INACTIVE then I18n.t('models.bs.customer.statuses.inactive')
    when CLOSED then I18n.t('models.bs.customer.statuses.closed')
    else '?'
    end
  end

  def balance_sms
    txt=%Q{აბ.##{self.accnumb} #{self.custname}. დღეისთვის თქვენი დავალიანება შეადგენს:
      \nსს "თელასი" (#{number_with_precision self.balance, precision: 2})GEL;
      \nდასუფთავება (#{number_with_precision self.trash_balance, precision: 2})GEL;
      \nწყალმომარაგება (#{number_with_precision self.water_balance, precision: 2})GEL.}
    deadline=self.cut_deadline
    txt+=%Q{\n\nდავალიანების დაფარვის ბოლო თარიღია #{deadline.strftime('%d-%b-%Y')}!} if deadline
    txt.to_ka
  end

  def to_s
    if self.commercial.present?
      a = "#{self.custname.to_ka} (#{self.commercial.to_ka})"
    else
      a = self.custname.to_ka
    end
    "#{self.accnumb.to_ka} -- #{a}"
  end
end
