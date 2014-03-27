# -*- encoding : utf-8 -*-
class Customer::Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :document_type, class_name: 'Customer::DocumentType'
  belongs_to :registation, class_name: 'Customer::Registration'
  field :complete, type: Mongoid::Boolean
end
