# -*- encoding : utf-8 -*-
class Webservice::EnergyLog

   include Mongoid::Document
   include Mongoid::Timestamps

   belongs_to :user,      class_name: 'Sys::User'           # მომხმარებელი
   field :parameters, :type => Hash

end