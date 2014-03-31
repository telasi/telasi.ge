# -*- encoding : utf-8 -*-
module Sap
	class MaterialText < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.MAKT"
	  self.primary_keys = [:mandt, :matnr, :spras]
	end
end