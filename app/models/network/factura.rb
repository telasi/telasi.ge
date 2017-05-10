# -*- encoding : utf-8 -*-
module Network::Factura

  def registered_facturas
  	Billing::NewCustomerFactura.where(cns: self.number)
  end
end
