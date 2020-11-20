# -*- encoding : utf-8 -*-
class Admin::GnercController < ApplicationController
  def index
    @title = 'სემეკი'
  end

  def parameters
    @param = params.permit(:number, :phase, :service)
    @application = Network::ChangePowerApplication.where(number: @param[:number]).first
    @parameters = @application.send_to_gnerc_admin(@param[:phase].to_i, @param[:service].to_i)
  end

  def check
    parameters = params[:postdata]
    file_key = params[:@parameters][":file_param"]
    file_param = params[:@parameters][":file"]
    file = Sys::File.find(file_param)

    content = File.read(file.file.file.file)
    content = Base64.encode64(content)

    parameters[file_key.to_sym] = content
    parameters["#{file_key}_filename".to_sym] = file.file.filename

    GnercWorker.perform_async(params[:stage] == '2' ? "answer" : "appeal", params[:service].to_i, parameters)
  end

  def realsend
  end
end
