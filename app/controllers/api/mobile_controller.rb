# -*- encoding : utf-8 -*-
class Api::MobileController < Api::ApiController
  def login
    validate_login do
      render json: { success: true, session_id: @session_id }
    end 
  end

  def user_info
    user = Sys::User.find(params[:session_id])
    if user
      @registrations = Customer::Registration.where(user: user)
    else 
      render json: { success: false, message: 'No user' }
    end
  end

  def bills
    customer = Billing::Customer.find(params[:custkey])
    if customer
      status, reason = customer.status
      render json: { success: true, 
                     status: status,
                     reason: reason,
                     energy: customer.payable_balance, 
                     trash: customer.trash_balance,
                     water: customer.current_water_balance || 0,
                     last_bill_date: customer.last_bill_date.strftime('%d/%m/%Y'),
                     last_bill_number: customer.last_bill_date ? customer.last_bill_number : '',
                     cut_deadline: customer.cut_deadline.strftime('%d/%m/%Y') }
    else 
      render json: { success: false, message: 'No customer' }
    end
  end

  def payments
    customer = Billing::Customer.find(params[:custkey])
    if customer
      type = params[:type] || '1'
      case type
        when '1'
          @payments = Billing::Payment.where(customer: customer).order('paykey desc').limit(10)
        when '2'
          @payments = Billing::WaterPayment.where(customer: customer).order('paykey desc').limit(10)
        when '3'
          @payments = Billing::TrashPayment.where(customer: customer).order('paykey desc').limit(10)
      end
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
