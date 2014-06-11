# -*- encoding : utf-8 -*-
module Sap
	class Orgname < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.HRP1000"
	  self.primary_keys = [:mandt, :plvar, :otype, :objid, :istat, :begda, :endda, :langu, :seqnr]
	end
end