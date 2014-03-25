# -*- encoding : utf-8 -*-
class Customer::Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :doctype, class_name: 'Customer::DocumentType'
  field :complete, type: Mongoid::Boolean
end
