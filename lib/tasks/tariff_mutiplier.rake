namespace :tariff_multiplier do

  START_DATE = Date.new(2019, 03, 01)
  END_DATE = Date.new(9999,1,1)

  TARIFFS_MULTIPLIER = [{
    file: 'data/tariff-multiplier.yml',
    starts: Date.new(2019,03,01),
    ends: nil
  }]


  def sync_one_multiplier(tariff)
    file = tariff[:file]
    d1 = tariff[:starts] || START_DATE
    d2 = tariff[:ends] || END_DATE

    YAML.load_file(file).values.each do |t|
      _id  = t['id']

      hash = { id: _id, starts: d1 }
      tariff = Network::TariffMultiplier.where(hash).first || Network::TariffMultiplier.new(hash)
      tariff.multiplier = t['multiplier'].to_f
      tariff.name = t['region_name']
      tariff.ends = d2
      tariff.save
    end
  end


  def sync_tariff_multiplier
    TARIFFS_MULTIPLIER.each { |tariff| sync_one_multiplier(tariff) }
  end


  task sync_tariff_multiplier: :environment do
    sync_tariff_multiplier
  end

end
