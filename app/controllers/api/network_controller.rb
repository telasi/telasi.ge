# -*- encoding : utf-8 -*-
class Api::NetworkController < Api::ApiController
  def newcustomer_sms
  	application = Network::NewCustomerApplication.where(number: params[:number]).first
    application.gnerc_id = "G0010#{params[:case_id]}F000#{params[:response_id]}"
    application.save
    application.first_sms
    render json: { success: true }
  end

  def changepower_sms
  	application = Network::ChangePowerApplication.where(number: params[:number]).first
    application.gnerc_id = "G0010#{params[:case_id]}F000#{params[:response_id]}"
    application.save
    application.first_sms
    render json: { success: true }
  end
end
