# -*- encoding : utf-8 -*-
module Sap
	class MaterialStockSPP < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.MSPR"
	  self.primary_keys = [:mandt, :matnr, :werks, :lgort, :charg, :sobkz]

	  def mat_name
	  	Sap::MaterialText.where(:mandt => self.mandt, :matnr => self.matnr, :spras => CartridgeInit::Sap::LANG_KA).first.maktx
	  end
	end
end