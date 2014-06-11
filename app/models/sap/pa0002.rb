# -*- encoding : utf-8 -*-
module Sap
	class Pa0002 < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.PA0002"
	  self.primary_keys = [:mandt, :pernr, :subty, :objps, :sprps, :endda, :begda, :seqnr]

	  def name
	  	case I18n.locale
	  	 when :ka
	  	 	"#{self.vorna} #{self.nachn}"
	  	 when :en
	  	 when :ru
	  	 	"#{self.fnamr} #{self.lnamr}"
	  	end 
	  end
	end
end