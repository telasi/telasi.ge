# -*- encoding : utf-8 -*-
class Stamba::Maintenance

   include Mongoid::Document
   include Mongoid::Timestamps

   belongs_to :printer,  class_name: 'Stamba::Printer'
   belongs_to :user,     class_name: 'Sys::User'
   field    :date ,      type: DateTime
   field	   :worktype,   type: String
end