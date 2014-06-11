# -*- encoding : utf-8 -*-
class Stamba::Printer

   include Mongoid::Document
   include Mongoid::Timestamps

   field    :invno,      type: String
   has_one  :model,      class_name: 'Stamba::Prn_model'
   field	   :ip, 		    type: String
   field    :conn_type,  type: String
   field    :serialno,   type: String
   field    :productid,  type: String
   field    :place,      type: String
   field    :adate, 	    type: Date

   has_many  :maintenance,      class_name: 'Stamba::Maintenance'
end