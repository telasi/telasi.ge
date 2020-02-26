# -*- encoding : utf-8 -*-
class Api::MobileController < Api::ApiController
  def login
    validate_login do
      render json: { success: true, session_id: @session_id }
    end 
  end

  def user_info
    @user = Sys::User.find(params[:session_id])
    if @user
      @registrations = Customer::Registration.where(user: @user)
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

  def subscription
    user = Sys::User.find(params[:session_id])
    if user
      @subscription = Sys::Subscription.where(email: user.email).first || Sys::Subscription.new
    else 
      render json: { success: false, message: 'No user' }
    end
  end 

  def update_subscription
    user = Sys::User.find(params[:session_id])
    if user
      subscription = user.subscription || Sys::Subscription.new(email: user.email)
      subscription.company_news = params[:company_news]
      subscription.procurement_news = params[:procurement_news]
      subscription.outage_news = params[:outage_news]
      subscription.locale = params[:locale]
      if subscription.save
        render json: { success: true, message: '' }
      end
    else 
      render json: { success: false, message: 'No user' }
    end
  end 

  def register
    user = Sys::User.new(params.permit(:email, :password, :password_confirmation, :first_name, :last_name, :mobile))
    if user.save
      user.send_confirmation
      render json: { success: true, message: '' }
    else 
      render json: { success: false, message: '' }
    end
  end

  def resend_sms
    user = Sys::User.find(params[:session_id])
    if user
      user.send_sms_confirmation 
      render json: { success: true, message: '' }
    else
      render json: { success: false, message: 'No user' }
    end
  end

  def confirm_sms
    user = Sys::User.find(params[:session_id])
    if user 
      if user.confirm_sms!(params[:sms_code]) 
        render json: { success: true, message: '' }
      else 
        render json: { success: false, message: user.seconds_left_for_resend, total: Sys::User::NEXT_RESEND_IN_MINUTES }
      end
    else
      render json: { success: false, message: 'No user' }
    end
  end

  def prepare_payment
    @payment = Pay::Payment.new(accnumb: params[:accnumb], clientname: params[:accnumb], rs_tin: rs_tin, amount: ( params[:amount] || 0 ), serviceid: params[:serviceid], merchant: get_current_merchant(params[:serviceid]) )
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
