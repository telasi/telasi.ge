# -*- encoding : utf-8 -*-
class Cartridge::Cartridge

   include Mongoid::Document
   include Mongoid::Timestamps

   field    :name,       type: String
   field    :manuf,      type: String
   field    :matnr,      type: String
   field    :maktx,      type: String
   field	:prop, 		 type: String
   field    :allow, 	 type: String
end