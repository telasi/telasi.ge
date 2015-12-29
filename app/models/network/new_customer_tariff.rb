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


  def days(app)
    case app.duration
    when NewCustomerApplication::DURATION_HALF
      days_to_complete_without_resolution
    when NewCustomerApplication::DURATION_DOUBLE
      days_to_complete_x2
    else
      days_to_complete
    end
  end


  def self.tariff_for(voltage, power, date=nil)
    date ||= Date.today
    tariffs = Network::NewCustomerTariff.where(voltage: voltage, :power_from.lte => power, :power_to.gte => power)
    tariffs = tariffs.where(:starts.lte => date, :ends.gte => date)
    tariffs.first
  end

end
