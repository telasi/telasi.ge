# -*- encoding : utf-8 -*-
class Network::MeterSetupTariff
  VOLTAGE_220 = '220'
  VOLTAGE_380 = '380'
  VOLTAGE_610 = '6/10'


  include Mongoid::Document
  include Mongoid::Timestamps


  field :voltage,    type: String
  field :power_from, type: Integer
  field :power_to,   type: Integer
  field :days_to_complete,                    type: Integer
  field :price_gel,  type: Float
  field :starts, type: Date
  field :ends,   type: Date


  def days(app); days_to_complete end


  def self.tariff_for(voltage, power, date=nil)
    date ||= Date.today
    tariffs = Network::MeterSetupTariff.where(voltage: voltage, :power_from.lt => power, :power_to.gte => power)
    tariffs = tariffs.where(:starts.lte => date, :ends.gte => date)
    tariffs.first
  end

end