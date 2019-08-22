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

  def bills
    user = Sys::User.find(params[:session_id])
    if user
      registration = Customer::Registration.where(user: user).first
      if registration
        customer = Billing::Customer.find(registration.custkey)
        if customer
          render json: { success: true, 
                         energy: customer.payable_balance, 
                         trash: customer.trash_balance,
                         water: customer.current_water_balance || 0,
                         last_bill_date: customer.last_bill_date.strftime('%d/%m/%Y'),
                         last_bill_number: customer.last_bill_date ? customer.last_bill_number : '',
                         cut_deadline: customer.cut_deadline.strftime('%d/%m/%Y') }
        else 
          render json: { success: false, message: 'No customer' }
        end
      else 
        render json: { success: false, message: 'No registration' }
      end
    else 
      render json: { success: false, message: 'No user' }
    end
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
