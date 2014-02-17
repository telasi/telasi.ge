# -*- encoding : utf-8 -*-
class Tender::TenderuserController < ApplicationController
  before_action :validate_login, only: [:index, :delete]
  before_action :validate_admin, only: [:index, :delete]

  def index
  	@search = params[:search] == 'clear' ? {} : params[:search]
  	ten = Tender::Tenderuser

    if @search
      ten = ten.where(organization_type: @search[:organization_type].mongonize) if @search[:organization_type].present?
      ten = ten.where(organization_name: @search[:organization_name].mongonize) if @search[:organization_name].present?
      ten = ten.where(director_name: @search[:director_name].mongonize) if @search[:director_name].present?
      ten = ten.where(fact_address: @search[:fact_address].mongonize) if @search[:fact_address].present?
      ten = ten.where(legal_address: @search[:legal_address].mongonize) if @search[:legal_address].present?
      ten = ten.where(phones: @search[:phones].mongonize) if @search[:phones].present?
      ten = ten.where(work_email: @search[:work_email].mongonize) if @search[:work_email].present?
      ten = ten.where(rs_tin: @search[:rs_tin]) if @search[:rs_tin].present?
    end

  	@tenderusers = ten.paginate(page: params[:page], per_page: 20)
  end

  def register
	if request.post?
	   @user = current_user || Sys::User.new(params.require(:tender_tenderuser).require(:sys_user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :mobile))
       @tenderuser = Tender::Tenderuser.new(params.require(:tender_tenderuser).permit(:organization_type, :organization_name, :director_name, :fact_address, :legal_address, :phones, :work_email, :rs_tin))
	   @tenderuser.user = @user

       if @user.valid?
    	 if @tenderuser.save
	      redirect_to register_complete_url
	   	 end
	   end
	else
	  @tenderuser = Tender::Tenderuser.new
	  @tenderuser.user = current_user || Sys::User.new
	end
  end

  private

  def validate_admin
    unless current_user.admin?
      redirect_to login_url, alert: 'საჭიროა იყოთ ქსელის ამინისტრატორი!'
    end
  end

end