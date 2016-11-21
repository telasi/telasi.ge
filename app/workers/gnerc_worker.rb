class GnercWorker
  include Sidekiq::Worker

  def perform(func, type, parameters)
  	service = "Newcust"
  	clazz = "Gnerc::#{service}".constantize
  	clazz.connection

  	if func == "appeal"
  		stage = 1
  		newcust = clazz.new(parameters)
  	else
  		stage = 2
  		newcust = clazz.where(letter_number: parameters["letter_number"]).first
  		newcust.update_attributes!(parameters.except("letter_number")) if newcust.present?
  	end
    if newcust.present?
  	  newcust.stage = stage
  	  newcust.save!
      queue = Gnerc::SendQueue.new(service: service, service_id: newcust.id, stage: stage, created_at: Time.now)
      queue.save!
    end
  end

end