# -*- encoding : utf-8 -*-
class Customer::Document
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :document_type, class_name: 'Customer::DocumentType'
  belongs_to :registration, class_name: 'Customer::Registration'
  has_one :file, class_name: 'Sys::File', as: 'mountable'
  field :complete, type: Mongoid::Boolean, default: false
  field :denied, type: Mongoid::Boolean, default: false
  field :denial_reason, type: String

  def file_name; file.name if self.file end
end
