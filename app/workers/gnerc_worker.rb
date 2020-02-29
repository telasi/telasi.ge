class GnercWorker
  include Sidekiq::Worker

  def perform(func, type, parameters)
    case type 
      when 7 then
        model = service = "Newcust"
      when 4 then
        model = service = "Docflow4"
      when 9 then
        model = service = "MeterSetup"
      when 10 then
        model = service = "ChangePower"
      when 11 then
        model = service = "MicroPower"
      when 12 then
        model = service = "TechCondition"
    end
  	clazz = "Gnerc::#{model}".constantize
  	clazz.connection

    newcust = clazz.where(letter_number: parameters["letter_number"]).first

  	if func == "appeal"
  		stage = 1
  		newcust = clazz.new(parameters) if newcust.blank?
  	else
  		stage = 2
  		newcust.update_attributes!(parameters.except("letter_number")) if newcust.present?
  	end
    if newcust.present?
  	  newcust.stage = stage
  	  newcust.save!
      if Gnerc::SendQueue.where(service: service, service_id: newcust.id, stage: stage).empty?
       Gnerc::SendQueue.new(service: service, service_id: newcust.id, stage: stage, created_at: Time.now).save!
      end
    end
  end

end