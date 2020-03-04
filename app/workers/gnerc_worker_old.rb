class GnercWorkerOld
  include Sidekiq::Worker

  def perform(func, type, parameters)
    case type 
      when 7 then
        model = "NewcustOld"
        service = "Newcust"
      when 4 then
        model = "Docflow4Old"
        service = 'Docflow4'
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
      if Gnerc::SendQueueOld.where(service: service, service_id: newcust.id, stage: stage).empty?
       Gnerc::SendQueueOld.new(service: service, service_id: newcust.id, stage: stage, created_at: Time.now).save!
      end
    end
  end

end