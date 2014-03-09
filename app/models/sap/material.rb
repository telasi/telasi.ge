# -*- encoding : utf-8 -*-
module Sap
	class Material < ActiveRecord::Base
	  self.table_name = "#{Cartridge::Sap::SCHEMA}.MARA"
	  self.primary_keys = [:mandt, :matnr]

	  def mat_name
	  	Sap::MaterialText.where(:mandt => self.mandt, :matnr => self.matnr, :spras => Cartridge::Sap::LANG_KA).first.maktx
	  end
	end
end