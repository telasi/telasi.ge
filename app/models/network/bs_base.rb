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
  ]

  def billing_items
    if @__billing_items
      @__billing_items
    elsif self.customer_id.present?
      @__billing_items = Billing::Item.where(custkey: self.customer_id, billoperkey: NETWORK_OPERATIONS).order('itemkey DESC')
    else
      @__billing_items = []
    end
  end
end
