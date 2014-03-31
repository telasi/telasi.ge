# -*- encoding : utf-8 -*-
module Sap
	class MaterialStock < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.MCHB"
	  self.primary_keys = [:mandt, :matnr, :werks, :lgort, :charg]

	  def mat_name
	  	Sap::MaterialText.where(:mandt => self.mandt, :matnr => self.matnr, :spras => CartridgeInit::Sap::LANG_KA).first.maktx
	  end
	end
end