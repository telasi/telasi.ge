# -*- encoding : utf-8 -*-
class Sys::BackgroundJob
  include Mongoid::Document
  include Mongoid::Timestamps

  NETWORK_NEWCUSTOMER_TO_XLSX = 'network-new-customer-to-xlsx'
  NETWORK_CHANGEPOWER_TO_XLSX = 'network-new-customer-to-xlsx'

  belongs_to :user, class_name: 'Sys::User'
  field :name, type: String
  field :data, type: String
  field :success, type: Mongoid::Boolean
  field :failed, type: Mongoid::Boolean
  field :trace, type: String
end
