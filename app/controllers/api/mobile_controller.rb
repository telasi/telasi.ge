# -*- encoding : utf-8 -*-
class Api::MobileController < Api::ApiController
  def login
    validate_login do
      render json: { success: true, session_id: @session_id, confirmed: true }
    end 
  end

  def user_info
    @user = Sys::User.find(params[:session_id])
    if @user
      @registrations = []
      Billing::Customer.where(fax: @user.mobile).each do |customer|
        @registrations << { id: "-1", 
                            custkey:         customer.custkey, 
                            customer_number: customer.accnumb.to_ka, 
                            customer_name:   customer.custname.to_ka,
                            status:          Customer::Registration::STATUS_COMPLETE,
                            regionkey:       customer.address.region.regionkey }
      end 
      Customer::Registration.where(user: @user).each do |registration|
        customer = Billing::Customer.find(registration.custkey)
        @registrations << { id:              registration.id.to_s, 
                            custkey:         registration.custkey, 
                            customer_number: customer.accnumb.to_ka, 
                            customer_name:   customer.custname.to_ka,
                            status:          registration.status,
                            regionkey:       customer.address.region.regionkey } unless customer.fax == @user.mobile
      end 
      render json: { success: true, registrations: @registrations }
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
      render json: { success: false, message: user.errors.full_messages }
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
    user = Sys::User.find(params[:session_id])
    merchant = Payge::PAY_SERVICES.find{ |h| h[:ServiceID] == service_id }[:Merchant]
    @payment = Pay::Payment.new(
          user:       user, 
          accnumb:    params[:accnumb],
          rs_tin:     '',
          serviceid:  params[:service_id],
          merchant:   merchant,
          amount:     params[:amount],
          clientname: params[:accnumb],
          testmode: Payge::TESTMODE, 
          ordercode: self.gen_order_code(merchant), currency: 'GEL', 
          lng: 'ka', ispreauth: 0, postpage: 0, gstatus: Pay::Payment::GSTATUS_SENT)

      @payment.generate_description
      @payment.prepare_for_step(Payge::STEP_SEND)
      @payment.user = user
      @payment.createdate = Time.now
      @payment.successurl = Payge::URLS[:success]
      @payment.cancelurl = Payge::URLS[:cancel]
      @payment.errorurl = Payge::URLS[:error]
      @payment.callbackurl = Payge::URLS[:callback]

      if @payment.save
        render json: { success: true, payment: { merchant:     @payment.merchant,
                                                 serviceid:    @payment.serviceid,
                                                 description:  @payment.description,
                                                 amount:       @payment.amount,
                                                 currency:     @payment.currency,
                                                 clientname:   @payment.clientname,
                                                 ordercode:    @payment.ordercode,
                                                 lng:          @payment.lng,
                                                 check:        @payment.check,
                                                 testmode:     @payment.testmode,
                                                 ispreauth:    @payment.ispreauth,
                                                 postpage:     @payment.postpage,
                                                 successurl:   @payment.successurl,
                                                 cancelurl:    @payment.cancelurl,
                                                 errorurl:     @payment.errorurl,
                                                 callbackurl:  @payment.callbackurl
                                                } }
      else
        render json: { success: false, message: @payment.errors.full_messages }
      end
  end

  def add_registration
    user = Sys::User.find(params[:session_id])
    if user
      customer = Billing::Customer.where(accnumb: params[:accnumb]).first
      if customer 
        if Customer::Registration.where(user: user, custkey: customer.custkey).blank?
          registration = Customer::Registration.new(customer_params)
          registration.custkey = customer.custkey
          registration.user = user
          if registration.save
            render json: { success: true, message: '' }
          else
            render json: { success: false, message: registration.errors.full_messages }  
          end
        else
          render json: { success: false, message: 'Already exists' }  
        end
      else 
        render json: { success: false, message: 'Cant find customer' }
      end
    else
      render json: { success: false, message: 'No user' }
    end
  end

  def delete_registration
    user = Sys::User.find(params[:session_id])
    if user
      Customer::Registration.find(params[:id]).destroy
      render json: { success: true, message: '' }
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
      render json: { success: true, session_id: @user.id, confirmed: false  }
    else 
      render json: { success: false, message: I18n.t('models.sys_user.errors.illegal_login') } 
    end
  end

  def customer_params; params.permit(:category, :rs_tin, :address, :address_code) end

  def gen_order_code(merchant)
    @seq = Pay::Sequence.find_and_modify( { "$inc" => { sequence: 1 } },
                                          { new: true }
                                          ) 
    if !@seq 
      @seq = Pay::Sequence.new

      @payment = Pay::Payment.where("merchant" => merchant).sort([['ordercode', -1]]).first

      @seq.sequence = @payment.ordercode + 1 if @payment
      @seq.sequence = 1 unless @payment
      @seq.save
    end

    @seq["sequence"]
  end
end
