# -*- encoding : utf-8 -*-
class Cartridge::CartridgeController < ActionController::Base
  require 'csv'
  layout 'cartridge/cartridge'

  def index
    @cartridges = Sap::Material.where(mandt: CartridgeInit::Sap::MANDT, matkl: CartridgeInit::Sap::MATNR_CLASS)
  end

  def update
  	if request.put?
  		params[:ids_hidden].each do |id|
  		  name = Sap::MaterialText.where(mandt: CartridgeInit::Sap::MANDT, matnr: id, spras: CartridgeInit::Sap::LANG_KA).first.maktx
  		  @newmat = Cartridge::Cartridge.new(matnr: id, maktx: name, allow: params[:ids].include?(id))
  		  @newmat.save
  	  end
  	  redirect_to cartridge_update_url
    else
	  	@mats = Sap::Material.where(mandt: CartridgeInit::Sap::MANDT, matkl: CartridgeInit::Sap::MATNR_CLASS)
	  	@materials = []

	    @mats.each do |m|
			@newmat = Cartridge::Cartridge.where(matnr: m.matnr).first
			if not @newmat
				@materials << m
		    end
	    end
	end
  end

  def list
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Cartridge::Cartridge.where(allow: true)

    if @search
      rel = rel.where(name: @search[:name].mongonize) if @search[:name].present?
      rel = rel.where(manuf: @search[:manuf].mongonize) if @search[:manuf].present?
      rel = rel.where(matnr: @search[:matnr]) if @search[:matnr].present?
      rel = rel.where(maktx: @search[:maktx]) if @search[:maktx].present?
    end

  	@cartridges = rel.paginate(page: params[:page], per_page: 20)
  end

  def edit
  	@cartridge = Cartridge::Cartridge.where(matnr: params[:matnr]).first
  	if request.patch?
  	 @cartridge.update_attributes(params.require(:cartridge_cartridge).permit(:manuf, :name, :prop))
     redirect_to cartridge_list_url
    end
  end

  def report
    if request.put?
      if params[:commit] == "Export to Excel"
        excel(params[:matnr], params[:quantity])
      else
        save_order(params[:matnr])
      end
    end

    @cartridges = []
    cartridges_not_ordered = []
    cartridge_list_ordered = Cartridge::Cartridge.where(:manuf.ne => nil, allow: true, :order.ne => nil).asc('manuf').asc('prop').asc('order')
    cartridge_list_notordered = Cartridge::Cartridge.where(:manuf.ne => nil, allow: true, order: nil).asc('manuf').asc('prop')

    cartridge_list_notordered.each do |nord|; cartridges_not_ordered << nord; end

    manuf = nil
    type = nil
    cartridge_list_ordered.each do |c|
      if ( manuf != c.manuf or type != c.prop )
        cartridges_not_ordered.each do |nord|
          next if nord.manuf != manuf or nord.prop != type
          @cartridges << nord
          nord.allow = false
        end
      end

      @cartridges << c

      manuf = c.manuf
      type = c.prop
    end

    cartridges_not_ordered.delete_if{ |nord| nord.allow == false}
    cartridges_not_ordered.each do |nord|; @cartridges << nord; end

    @cartridges.each do |e|
      e.saldo = get_material_stock(e.matnr, '1000', params[:lgort])
    end

    @table_list = []
  end

  def get_material_stock(matnr, werks, lgort)
    stock = 0
    @normal_stock = Sap::MaterialStock.where(mandt: CartridgeInit::Sap::MANDT, matnr: matnr, werks: werks, lgort: lgort)
    @spp_stock    = Sap::MaterialStockSPP.where(mandt: CartridgeInit::Sap::MANDT, matnr: matnr, werks: werks, lgort: lgort)
    @normal_stock.each do |n|
      stock += n.clabs + n.cinsm + n.cspem + n.ceinm + n.cretm
    end
    @spp_stock.each do |s|
      stock += s.prlab + s.prins + s.prspe + s.prein
    end
    return stock
  end

  def save_order(matnr)
    i = 1
    matnr.each do |item|
     @cartridge = Cartridge::Cartridge.where(matnr: item).first
     if @cartridge
       @cartridge.order = i
       @cartridge.save
       i += 1
     end 
    end
  end

  def to_csv(cartridges)
    raise 'xxx'
    CSV.generate do |csv|
      csv << [ 'ID', 'Name', 'Saldo']
      cartridges.each do |cart|
        csv << [ cart.matnr, cart.name, cart.saldo ]
      end
    end
  end

  def excel(matnr, quantity)
    @cartridges = []
    matnr.each_with_index do |m, i|
      next if quantity[i].to_i == 0
      catr = Cartridge::Cartridge.where(:matnr => m).first
      catr.saldo = quantity[i]
      @cartridges << catr
    end
    respond_to do |format|
      format.html
      format.csv { send_data to_csv(@cartridges) }
    end
  end

end
