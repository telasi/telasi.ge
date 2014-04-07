# -*- encoding : utf-8 -*-
class Billing::Customer < ActiveRecord::Base
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
  # def last_water_item; self.water_items.last end
  # def water_balance; self.last_water_item.new_balance rescue 0 end
  # def current_water_balance; self.last_water_item.curr_charge rescue 0 end
  def water_balance; self.water_customer.new_balance rescue 0 end
  def current_water_balance; self.water_customer.curr_charge rescue 0 end
  def trash_balance; self.trash_customer.balance rescue 0 end
  def last_bill_date; self.item_bills.last.billdate end
  def last_bill_number; self.item_bills.last.billnumber end
  def cut_deadline; self.item_bills.last.lastday end

  def cut_candidate?
    if self.except then false
    else self.balance > 0.5 or self.trash_balance > 0.5 or self.current_water_balance > 0.5 end
  end

  def pre_payment; Billing::Payment.where('paydate > ? AND custkey = ? AND status = 1', Date.today - 7, self.custkey).inject(0) { |sum, payment| sum += payment.amount } end
  def pre_payment_date; Billing::Payment.where('paydate > ? AND custkey = ? AND status = 1', Date.today - 7, self.custkey).order('paykey desc').first.paydate rescue nil end
  def pre_water_payment
    Billing::WaterPayment.where('paydate > ? AND custkey = ? AND status = 1', Date.today - 7, self.custkey).inject(0) do |sum, payment|
      sum += payment.amount
    end
  end
  def pre_water_payment_date; Billing::WaterPayment.where('paydate > ? AND custkey = ? AND status = 1', Date.today - 7, self.custkey).order('paykey desc').first.paydate rescue nil end

  def status_name
    case self.statuskey
    when ACTIVE then I18n.t('models.bs.customer.statuses.active')
    when INACTIVE then I18n.t('models.bs.customer.statuses.inactive')
    when CLOSED then I18n.t('models.bs.customer.statuses.closed')
    else '?'
    end
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
