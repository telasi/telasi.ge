# -*- encoding : utf-8 -*-
class Sys::Role
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  belongs_to :actor, polymorphic: true
  validates :name, presence: { message: 'ჩაწერეთ დასახელება' }
end
