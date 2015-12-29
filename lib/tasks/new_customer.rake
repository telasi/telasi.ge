namespace :new_customer do

  task sync: :environment do
    clazz = Network::NewCustomerApplication
    clazz.all.each do |app|
      duration = app.need_resolution ? clazz::DURATION_HALF : clazz::DURATION_STANDARD
      app.update!(duration: duration)
    end
  end

end
