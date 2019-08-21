# -*- encoding : utf-8 -*-
class Api::MobileController < Api::ApiController
  def login
    validate_login do
      render json: { success: true, session_id: @session_id }
    end 
  end

  def get_user_info
    validate_loginc do
      registration = Customer::Registration.where(user: @user).first
      if registration
        customer = Billing::Customer.find(registration.custkey)  
      end
      if customer
        render json: { success: true, 
                       customer_number: customer.accnumb.to_ka, 
                       customer_name: customer.custname.to_ka } 
      else 
        render json: { success: false, message: 'No registration' }
      end
    end
  end

  def debts
  end

  private

  def validate_login
    @user = Sys::User.authenticate(params[:username].downcase, params[:password]) if params[:username]
    if @user and @user.email_confirmed and @user.active 
      @session_id = @user.id
      yield if block_given?
    elsif @user and not @user.email_confirmed then 
      render json: { success: false, message: I18n.t('model.sys_user.errors.email_not_confirmed') }
    else 
      render json: { success: false, message:  I18n.t('models.sys_user.errors.illegal_login') } 
    end
  end
end
