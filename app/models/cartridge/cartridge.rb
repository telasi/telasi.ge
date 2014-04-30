# -*- encoding : utf-8 -*-
class Cartridge::Cartridge

   include Mongoid::Document
   include Mongoid::Timestamps

   field    :name,       type: String
   field    :manuf,      type: String
   field	   :prop, 		 type: String
   field    :matnr,      type: String
   field    :maktx,      type: String
   field    :saldo,      type: Float
   field    :allow, 	    type: Boolean
   field    :order,      type: Integer

   CARTRIDGETYPES = [ 'Laser Color', 'Laser BW', 'Ink Color', 'Ink BW', 'Matrix' ]   
end
