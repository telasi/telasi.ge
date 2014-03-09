# -*- encoding : utf-8 -*-
module Sap
	class MaterialStock < ActiveRecord::Base
	  self.table_name = "#{Cartridge::Sap::SCHEMA}.MBEW"
	  self.primary_keys = [:mandt, :matnr, :bwkey, :bwtar]

	  def mat_name
	  	Sap::MaterialText.where(:mandt => self.mandt, :matnr => self.matnr, :spras => Cartridge::Sap::LANG_KA).first.maktx
	  end
	end
end