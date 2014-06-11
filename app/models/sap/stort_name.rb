# -*- encoding : utf-8 -*-
module Sap
	class StortName < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.T499S"
	  self.primary_keys = [:mandt, :werks, :stand]
	end
end