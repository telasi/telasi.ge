# -*- encoding : utf-8 -*-
class Sys::BackgroundJob
  include Mongoid::Document
  include Mongoid::Timestamps
  include Sys::BackgroundJobConstants

  belongs_to :user, class_name: 'Sys::User'
  field :name, type: String
  field :data, type: String
  field :success, type: Mongoid::Boolean, default: false
  field :failed,  type: Mongoid::Boolean, default: false
  field :trace, type: String

  def completed?; self.success or self.failed end
end
