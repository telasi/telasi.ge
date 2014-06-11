# -*- encoding : utf-8 -*-
class Stamba::PrinterController < ActionController::Base
  layout 'stamba/stamba'

  def index 
  end

  def list
  end

  def asset
  	@models = Stamba::Prn_model.all
  	@asset = Sap::Asset.where(mandt: CartridgeInit::Sap::MANDT, invnr: params[:invno]).order(bdatu: :desc).last

	if request.post? or request.patch?
	   @printer = Stamba::Printer.where(invno: params[:stamba_printer][:invno]).first 
	   if @printer
	    @printer.update_attributes(params.require(:stamba_printer).permit(:invno, :model, :ip, :conn_type, :serialno, :productid, :place, :adate))
	   else
	   	@printer = Stamba::Printer.new(params.require(:stamba_printer).permit(:invno, :model, :ip, :conn_type, :serialno, :productid, :place, :adate))
	   	@printer.save
	   end
    else
       @printer = Stamba::Printer.where(invno: params[:invno]).first || Stamba::Printer.new
    end

  	if not @asset
  		redirect_to stamba_find_url
    end
  end
end