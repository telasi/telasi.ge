# -*- encoding : utf-8 -*-
class Network::BaseClass
  STATUS_DEFAULT    = 0
  STATUS_SENT       = 1
  STATUS_CANCELED   = 2
  STATUS_CONFIRMED  = 3
  STATUS_COMPLETE   = 4
  STATUS_IN_BS      = 5
  STATUS_USER_DECLINED = 6
  STATUSES = [ STATUS_DEFAULT, STATUS_SENT, STATUS_CANCELED, STATUS_CONFIRMED, STATUS_COMPLETE, STATUS_IN_BS, STATUS_USER_DECLINED ]
  STATUSES_REPORT_BY_STATUS = [ STATUS_SENT, STATUS_CANCELED, STATUS_CONFIRMED, STATUS_COMPLETE, STATUS_IN_BS, STATUS_USER_DECLINED ]
  VOLTAGE_220 = '220'
  VOLTAGE_380 = '380'
  VOLTAGE_610 = '6/10'
  VOLTAGE_35110 = '35/110'

  DURATION_STANDARD = 2
  DURATION_HALF     = 1
  DURATION_DOUBLE   = 3
  ABONENT_AMOUNT_DEFAULT = 1

  def customer; Billing::Customer.find(self.customer_id) if self.customer_id.present? end
  def bank_name; Bank.bank_name(self.bank_code) if self.bank_code.present? end
  def self.status_name(status); I18n.t("models.network_change_power_application.status_#{status}") end
  def self.status_icon(status)
    case status
    # when STATUS_DEFAULT    then '/icons/mail-open.png'
    when STATUS_SENT          then '/icons/mail-send.png'
    when STATUS_CANCELED      then '/icons/cross.png'
    when STATUS_CONFIRMED     then '/icons/clock.png'
    when STATUS_COMPLETE      then '/icons/tick.png'
    when STATUS_IN_BS         then '/icons/lock.png'
    when STATUS_USER_DECLINED then '/icons/thumb.png'
    else '/icons/mail-open.png' end
  end
  def status_name; Network::BaseClass.status_name(self.status) end
  def status_icon; Network::BaseClass.status_icon(self.status) end
  def self.customer_type_name(type); I18n.t("models.network_change_power_application.customer_type_id_#{type}") end
  def customer_type_name; Network::BaseClass.customer_type_name(self.customer_type_id) end

  def self.duration_collection
    {
      'სტანდარტული'  => Network::BaseClass::DURATION_STANDARD,
      'განახევრებული' => Network::BaseClass::DURATION_HALF,
      'გაორმაგებული'  => Network::BaseClass::DURATION_DOUBLE
    }
  end

  def duration_name
    self.class.duration_collection.invert[duration]
  end

  def calculate_region
    self.tariff_multiplier = Network::TariffMultiplier.multiplier_for(self.address_code, self.start_date)
    self.region = self.tariff_multiplier.name if self.tariff_multiplier
  end

  def real_days
    d1 = self.send_date
    d2 = self.end_date || Date.today
    if self.use_business_days
      d1.business_days_until(d2) + 1 if d1
    else
      d2 - d1 + 1 if d1
    end
  end

  def payments; self.billing_items.select { |x| [116,1005,1012].include?(x.billoperkey) } end
  def paid
    calc_date = self.end_date || Time.now.to_date
    self.payments.select{ |x| x.itemdate >= ( calc_date - 1.years )}.map{ |x| x.operation.opertpkey == 3 ? x.amount : -x.amount }.inject{ |sum, x| sum + x } || 0  
  end
  def remaining
    if self.amount.present?
      if self.effective_amount < 0
        0
      else
        self.amount - self.paid
      end
    else
      0
    end
  end

  # ჯარიმის სრული ოდენობა.
  def total_penalty; self.penalty_first_stage end

  # რეალურად გადასახდელი თანხა.
  def effective_amount; self.amount - self.total_penalty rescue 0 end

  # პირველი ეტაპის ჯარიმა.
  def penalty_first_stage
    if self.status != STATUS_CANCELED and self.send_date and self.start_date
      if real_days > ( days + ( total_overdue_days || 0 ) )
        self.amount / 2
      else 0 end
    else 0 end
  end

  def calculate_plan_end_date
    return unless self.send_date
    self.total_overdue_days = 0

    date_array = []

    self.overdue.where(chosen: true).map do |overdue|
      date_array = date_array | (overdue.deadline..overdue.response_date).to_a
    end

    date_array.compact!
    date_array.sort!

    prev = date_array[0]

    periods = date_array.slice_before{ |e|
      prev, prev2 = e, prev
      prev2 + 1 != e
    }.map{|b,*,c| c ? (b..c) : b }

    periods.each{ |p| self.total_overdue_days = self.total_overdue_days + p.min.business_days_until(p.max) }

    if self.use_business_days
      # self.plan_end_date = self.days.business_days.after( self.send_date )
      self.plan_end_date = (self.days - 1).business_days.after( self.send_date )
      self.plan_end_date = (self.total_overdue_days).business_days.after( self.plan_end_date )
    else
      self.plan_end_date = self.send_date + self.days
      self.plan_end_date = self.plan_end_date + self.total_overdue_days
    end
  end

end