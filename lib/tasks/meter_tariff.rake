namespace :meter_setup_tariff do

  START_DATE = Date.new(2020, 01, 1)
  END_DATE = Date.new(9999,1,1)

  METER_TARIFFS = [{
    file: 'data/meter-tariffs.yml',
    starts: Date.new(2020,1,1),
    ends: nil
  }]

  def sync_meter_tariff(tariff)
    file = tariff[:file]
    d1 = tariff[:starts] || START_DATE
    d2 = tariff[:ends] || END_DATE

    YAML.load_file(file).values.each do |t|
      from, to = t['power_kwt'].split('-').map{ |p| p.to_i }
      voltage  = t['voltage']
      hash = { power_from: from, power_to: to, voltage: voltage, starts: d1 }
      tariff = Network::MeterSetupTariff.where(hash).first || Network::MeterSetupTariff.new(hash)
      tariff.days_to_complete = t['days_to_complete'].to_i
      tariff.ends = d2
      tariff.price_gel = t['price_gel'].to_f
      tariff.save
    end
  end

  def sync_meter_tariffs
    METER_TARIFFS.each { |tariff| sync_meter_tariff(tariff) }
  end

  task sync_meter: :environment do
    sync_meter_tariffs
  end

end