# -*- encoding : utf-8 -*-
class Sys::Role
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  validates :name, presence: { message: 'ჩაწერეთ დასახელება' }

  def users; Sys::User.where(:role_ids.in => [ self.id ]) end
end
