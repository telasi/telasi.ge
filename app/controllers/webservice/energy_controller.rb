# -*- encoding : utf-8 -*-
class Webservice::EnergyController < ApplicationController
 protect_from_forgery with: :null_session
 before_action :validate_webservice_login, :except => [:testform] 
 before_action :validate_admin, :only => [:testform] 

 def testform 
 end

 def index
  @energy = Webservice::Energy.all
  @energy = @energy.where(accnumb: params[:accnumb]) if params[:accnumb].present?
  @energy = @energy.where("itemdate >= ?", params[:start_year]+params[:start_month].to_s.rjust(2, "0")) if params[:start_month].present?
  @energy = @energy.where("itemdate <= ?", params[:end_year]+params[:end_month].to_s.rjust(2, "0")) if params[:end_month].present?
 end

 private

  def validate_webservice_login
  	user = Sys::User.authenticate(params[:username].downcase, params[:password]) if params[:username]
  	if !user || !user.roles.where(name: 'EnergyWebServiceCustomer').first
  	 render text: 'No authenticated'
  	end
  end

  def validate_admin
  	current_user.admin? if current_user
  end
end
