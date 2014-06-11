# -*- encoding : utf-8 -*-
class Tender::Protocol
   include Mongoid::Document
   include Mongoid::Timestamps

   field    :title,      type: String
   field    :comment,    type: String 
   has_many :files,  	 class_name: 'Sys::File', as: 'mountable'

end
