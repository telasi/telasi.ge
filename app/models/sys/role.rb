# -*- encoding : utf-8 -*-
class Sys::Role
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
end
