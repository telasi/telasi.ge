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
  validate :validate_denial_reason

  def can_deny?; self.file and !denied end
  def has_file?; self.file.present? end

  private

  def validate_denial_reason
    if self.denied
      if self.denial_reason.blank?
        errors.add(:denial_reason, 'ჩაწერეთ უარყოფის მიზეზი')
      end
    end
  end
end
