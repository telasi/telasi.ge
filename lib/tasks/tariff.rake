namespace :tariff do

  START_DATE = Date.new(2014, 1, 1)
  END_DATE = Date.new(9999,1,1)

  TARIFFS = [{
    file: 'data/new-customer-tariffs.yml',
    starts: nil,
    ends: Date.new(2015,9,30)
  }, {
    file: 'data/new-customer-tariffs2.yml',
    starts: Date.new(2015,10,1),
    ends: Date.new(2019,8,12)
  }, {
    file: 'data/new-customer-tariffs3.yml',
    starts: Date.new(2019,8,13),
    ends: END_DATE
  }]


  def sync_tariff(tariff)
    file = tariff[:file]
    d1 = tariff[:starts] || START_DATE
    d2 = tariff[:ends] || END_DATE

    YAML.load_file(file).values.each do |t|
      from, to = t['power_kwt'].split('-').map{ |p| p.to_i }
      voltage  = t['voltage']
      hash = { power_from: from, power_to: to, voltage: voltage, starts: d1 }
      tariff = Network::NewCustomerTariff.where(hash).first || Network::NewCustomerTariff.new(hash)
      tariff.days_to_complete = t['days_to_complete'].to_i
      tariff.days_to_complete_x2 = t['days_to_complete_x2'] ? t['days_to_complete_x2'].to_i : nil
      tariff.days_to_complete_without_resolution = t['days_to_complete_without_resolution'].to_i
      tariff.ends = d2
      tariff.price_gel = t['price_gel'].to_f
      tariff.save
    end
  end


  def fix_dates
    Network::NewCustomerTariff.each do |tariff|
      tariff.starts ||= START_DATE
      tariff.ends ||= END_DATE
      tariff.save
    end
  end


  def sync_tariffs
    fix_dates
    TARIFFS.each { |tariff| sync_tariff(tariff) }
  end


  task sync: :environment do
    # sync_tariffs
  end

end
