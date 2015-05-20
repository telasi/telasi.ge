# -*- encoding : utf-8 -*-
class SignatureController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
	@application = Network::NewCustomerApplication.find(params[:id])
	
	filepath = File.join(Rails.root, 'public', 'uploads', params[:filename])
	f = File.open(filepath, "wb")
	f.write(params.require(:sys_file).permit(:file)[:file])

	options = { file: f	}
	@file = Sys::File.new(options)
	if @file.save
	  @application.files << @file
	end

	File.delete(filepath) if File.exist?(filepath)

    render text: "asdasd"
  end
end
