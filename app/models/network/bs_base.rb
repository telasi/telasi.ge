# -*- encoding : utf-8 -*-
module Network::BsBase
  NETWORK_OPERATIONS = [
    116,   # prepayment
    1000,  # charge: new_customer_application
    1001,  # charge: change_power_application
    1006,  # penalty I
    1007,  # penalty II
    120,   # penalty III
    1008,  # charge correction
    1009,  # penalty I correction
    1010,  # penalty II correction
    1012,
    1004,
    1005,
    1025
  ]

  PREPAYMENT_OPERATIONS = [
    116,
    1012
  ]

  OPERATIONS_MINUS = [
    116
  ]

  NEW_CUST_OPERATIONS = [
    1000
  ]

  def billing_items
    if @__billing_items
      @__billing_items
    elsif self.customer_id.present?
      @__billing_items = Billing::Item.where(custkey: self.customer_id, billoperkey: NETWORK_OPERATIONS).order('item.itemkey DESC')
    else
      @__billing_items = []
    end
  end

  def billing_items_united
    billing_items
  end

  def billing_items_chosen
    billing_items.joins(:cns)
  end

  def billing_items_effective
    Billing::Item.where('itemdate >= ?', Network::PREPAYMENT_START_DATE)
  end

  def billing_items_raw
    self.billing_items_effective.joins('join bs.customer a on item.custkey = a.custkey')
                                .joins('join bs.customer b on itemnumber = b.accnumb')
                                .where('a.accnumb = ? and b.custkey = ?', Billing::Customer::XXX, self.customer_id).where(billoperkey: NETWORK_OPERATIONS).order('itemkey DESC')
  end

  def billing_items_raw_sum
    self.billing_items_raw.sum(:amount)
  end

  def billing_items_raw_to_factured
    self.billing_items_effective.joins('join bs.customer a on item.custkey = a.custkey')
                                .joins('join bs.customer b on itemnumber = b.accnumb')
                                .where('a.accnumb = ? and b.custkey = ?', Billing::Customer::XXX, self.customer_id).where(billoperkey: NETWORK_OPERATIONS)
                                .eager_load(:factura).where('new_customer_factura_appl.id is null')
  end

  def billing_items_raw_to_factured_sum
    self.billing_items_raw_to_factured.sum(:amount)
  end

  def billing_prepayment
    self.billing_items_effective.eager_load(:factura).where(custkey: self.customer_id, billoperkey: PREPAYMENT_OPERATIONS).order('item.itemkey DESC')
  end

  def billing_prepayment_sum
    self.billing_items_effective.eager_load(:factura).where(custkey: self.customer_id, billoperkey: PREPAYMENT_OPERATIONS).sum(:amount)
  end

  def billing_prepayment_factura
    self.billing_prepayment.where('new_customer_factura_appl.id is not null')
  end

  def billing_prepayment_factura_sum
    self.billing_prepayment.where('new_customer_factura_appl.id is not null').sum(:amount)
  end

  def billing_prepayment_to_factured
    self.billing_prepayment.where('new_customer_factura_appl.id is null')
  end

  def billing_prepayment_to_factured_sum
    self.billing_prepayment.where('new_customer_factura_appl.id is null').sum(:amount)
  end

  def billing_prepayment_total
    ( self.billing_prepayment.where.not(billoperkey: OPERATIONS_MINUS).sum(:amount) + 
      self.billing_prepayment.where(billoperkey: OPERATIONS_MINUS).sum(:amount) * (-1) + 
      self.billing_items_raw.where.not(billoperkey: OPERATIONS_MINUS).sum(:amount) + 
      self.billing_items_raw.where(billoperkey: OPERATIONS_MINUS).sum(:amount) * (-1) ).abs
  end

  def has_new_cust_charge?
    Billing::Item.where(custkey: self.customer_id, billoperkey: NEW_CUST_OPERATIONS).present?
  end

  def billing_prepayment_chosen
    self.billing_prepayment.joins(:cns)
  end

  def billing_prepayment_chosen_to_factured
    self.billing_prepayment.joins(:cns).where('new_customer_factura_appl.id is null')
  end

  def billing_prepayment_chosen_to_factured_sum
    self.billing_prepayment.joins(:cns).where('new_customer_factura_appl.id is null').sum(:amount)
  end

  def billing_prepayment_not_chosen
    self.billing_prepayment.eager_load(:cns).where('network_operations.itemkey is null')
  end

  def billing_prepayment_not_chosen_to_factured
    self.billing_prepayment.eager_load(:cns).where('network_operations.itemkey is null').where('new_customer_factura_appl.id is null')
  end

  def add_operation!(itemkey)
    app = self.class == Network::NewCustomerApplication ? 'NC' : 'CP'
    Billing::NetworkOperation.new(application: app, cns: self.number, itemkey: itemkey).save
  end

  def remove_operation!(itemkey)
    operation = Billing::NetworkOperation.where(itemkey: itemkey).first
    operation.destroy if operation.present?
  end
end
