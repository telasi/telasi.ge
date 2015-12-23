# -*- encoding : utf-8 -*-
class Network::NewCustomerTariff
  VOLTAGE_220 = '220'
  VOLTAGE_380 = '380'
  VOLTAGE_610 = '6/10'

  include Mongoid::Document
  include Mongoid::Timestamps

  field :voltage,    type: String
  field :power_from, type: Integer
  field :power_to,   type: Integer
  field :days_to_complete,                    type: Integer
  field :days_to_complete_without_resolution, type: Integer
  field :days_to_complete_x2,                 type: Integer
  field :price_gel,  type: Float
  field :starts, type: Date
  field :ends,   type: Date

  def self.tariff_for(voltage, power, date=nil)
    Network::NewCustomerTariff.each do |t|
      return t if t.voltage == voltage and power >= t.power_from and power <= t.power_to
    end
    nil
  end
end
