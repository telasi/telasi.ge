# -*- encoding : utf-8 -*-
class Network::TariffMultiplier
  include Mongoid::Document
  include Mongoid::Timestamps

  field :id,    type: String
  field :name,  type: String
  field :multiplier,  type: Float
  field :starts, type: Date
  field :ends,   type: Date

  def self.multiplier_for(cadastral, date=nil)
    date ||= Date.today

    tariffs = Network::TariffMultiplier.where(:starts.lte => date, :ends.gte => date).desc(:_id)
    tariffs.to_a.find{ |tariff| tariff.id == cadastral[0..tariff.id.length-1]}
  end

end
