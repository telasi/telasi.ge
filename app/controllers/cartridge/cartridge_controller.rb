# -*- encoding : utf-8 -*-
class Cartridge::CartridgeController < ActionController::Base
  layout 'cartridge/cartridge'

  def index
    @cartridges = Sap::Material.where(mandt: Cartridge::Sap::MANDT, matkl: Cartridge::Sap::MATNR_CLASS)
  end

  def update
  	if request.put?
  		params[:ids_hidden].each do |id|
  		  name = Sap::MaterialText.where(mandt: Cartridge::Sap::MANDT, matnr: id, spras: Cartridge::Sap::LANG_KA).first.maktx
  		  @newmat = Cartridge::Cartridge.new(matnr: id, maktx: name, allow: params[:ids].include?(id))
  		  @newmat.save
  	    end
  	    redirect_to cartridge_update_url
    else
	  	@mats = Sap::Material.where(mandt: Cartridge::Sap::MANDT, matkl: Cartridge::Sap::MATNR_CLASS)
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
  	@cartridges = Cartridge::Cartridge.where(allow: true)
  	@cartridges = @cartridges.paginate(page: params[:page], per_page: 20)
  end

  def edit
  	@cartridge = Cartridge::Cartridge.where(matnr: params[:matnr]).first
  	if request.patch?
  	 @cartridge.update_attributes(params.require(:cartridge_cartridge).permit(:manuf, :name, :prop))
    end
  end

  def report
    @cartridges = Cartridge::Cartridge.where(:manuf.ne => nil, allow: true).asc('manuf')
  end

end