# -*- encoding : utf-8 -*-
module Sap
	class Asset < ActiveRecord::Base
	  self.table_name = "#{CartridgeInit::Sap::SCHEMA}.V_ANLAZ"
	  self.primary_keys = [:mandt, :bukrs, :anln1, :anln2, :bdatu]

	  def stort_name
	  	Sap::StortName.where(:mandt => self.mandt, :werks => self.werks, :stand => self.stort).first.ktext
	  end

	  def mol_name
	  	@prnr = Sap::Pa0002.where(:mandt => self.mandt, :pernr => self.pernr, :endda => '99991231').first.name
	  end

	  def mol_orgname
	  	@orgeh = Sap::Pa0001.where(:mandt => self.mandt, :pernr => self.pernr, :endda => '99991231').first.orgeh
	  	@orgname = Sap::Orgname.where(:mandt => self.mandt, :plvar => '01', :otype => 'O', :objid => @orgeh, :istat => '1', :endda => '99991231', :langu => CartridgeInit::Sap::LANG_KA).order(endda: :desc).first.stext
	  end
	end
end