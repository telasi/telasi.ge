# -*- encoding : utf-8 -*-
module Network::Factura
  require 'rs'

  def registered_facturas
  	Billing::NewCustomerFactura.where(cns: self.number)
  end

  def correct_factures
  	if penalty2 > 0
  	  amount_to_return = self.billing_prepayment_factura_sum
  	elsif penalty1 > 0
  	  amount_to_return = self.billing_prepayment_factura_sum - self.amount / 2
  	end

  	return unless amount_to_return > 0

	registered_facturas.where(category: Billing::NewCustomerFactura::ADVANCE).each do |factura|
		break unless ( amount_to_return > 0 )

		if factura.amount > amount_to_return
			new_amount = factura.amount - amount_to_return
			amount_to_return = 0
		else
			new_amount = 0
			amount_to_return =- factura.amount
		end

		correct_factura_amount(factura, new_amount)
	end

  end

  def correct_factura_amount(factura, amount)
    rs_factura = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.factura_id))
    raise 'Could not get factura' unless rs_factura.present?

    case rs_factura.status.to_i
      when RS::Factura::SENT
      	editable_factura    = rs_factura
      when RS::Factura::CONFIRMED
        editable_factura_id = RS.correct_factura(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.factura_id, k_type: RS::Factura::RETURNED_GOODS))
        editable_factura    = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: editable_factura_id))
    end

    raise 'Could not create correcting factura' if editable_factura_id.blank?

    items = RS.get_factura_items(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: editable_factura.id))
    items.each do |item|
    	item.amount = amount
    	item.factura = editable_factura
    	raise 'Could not save factura item' unless RS.save_factura_item(item, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID))
    end
    if rs_factura.status.to_i == RS::Factura::CONFIRMED
     raise 'Could not send factura' unless RS.send_factura(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: editable_factura_id))
    end
    new_factura = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: editable_factura.id))

    Billing::NewCustomerFactura.transaction do 
        billing_factura = Billing::NewCustomerFactura.new(application: 'NC',
                                                          cns: self.number, 
                                                          factura_id: new_factura.id, 
                                                          factura_seria: new_factura.seria.to_geo, 
                                                          factura_number: new_factura.number,
                                                          category: Billing::NewCustomerFactura::CORRECTING1,
                                                          base_id: rs_factura.id,
                                                          amount: amount, period: Time.now)
        billing_factura.save

        billing_factura_appl = Billing::NewCustomerFacturaAppl.new(itemkey: factura.appl.itemkey, 
        														   custkey: self.customer.custkey, 
                                                                   application: 'NC',
                                                                   cns: self.number, 
                                                                   start_date: self.start_date,
                                                                   plan_end_date: self.plan_end_date,
                                                                   factura_id: billing_factura.id,
                                                                   factura_date: Time.now)
        billing_factura_appl.save  
    end

  end



end
