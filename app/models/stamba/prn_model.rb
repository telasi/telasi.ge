# -*- encoding : utf-8 -*-
class Stamba::Prn_model

   include Mongoid::Document
   include Mongoid::Timestamps

   belongs_to :printer,    class_name: 'Stamba::Printer'

   field    :unittype,     type: String
   field    :prntype,      type: String
   field	   :color, 	  	   type: String
end