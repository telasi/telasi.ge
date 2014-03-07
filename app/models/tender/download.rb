# -*- encoding : utf-8 -*-
class Tender::Download

   include Mongoid::Document
   include Mongoid::Timestamps

   belongs_to :tenderuser,    class_name: 'Tender::Tenderuser'

   field :nid,          type: Integer
   field :datetime, 	   type: DateTime

end
