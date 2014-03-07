# -*- encoding : utf-8 -*-
class Tender::Tender

   include Mongoid::Document
   include Mongoid::Timestamps

   field    :nid,      type: Integer
   field    :tenderno, type: String 
   has_many :file,  	  class_name: 'Sys::File', as: 'mountable'

end
