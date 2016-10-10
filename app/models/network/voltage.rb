# -*- encoding : utf-8 -*-
class Network::Voltage
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :application, class_name: 'Network::ChangePowerApplication', inverse_of: :voltages
  field :voltage,     type: String
  field :power,       type: Float
  belongs_to :tariff, class_name: 'Network::NewCustomerTariff'

  validates :voltage, presence: { message: I18n.t('models.network_new_customer_application.errors.volt_required') }
  validates :power, numericality: { message: I18n.t('models.network_new_customer_item.errors.illegal_power') }
end