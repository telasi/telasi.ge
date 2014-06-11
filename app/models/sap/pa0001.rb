# -*- encoding : utf-8 -*-
module Sap
	class Pa0001 < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.PA0001"
	  self.primary_keys = [:mandt, :pernr, :subty, :objps, :sprps, :endda, :begda, :seqnr]
	end
end