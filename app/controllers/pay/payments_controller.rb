# -*- encoding : utf-8 -*-
class Pay::PaymentsController < ApplicationController
  #before_action :validate_users, :except => [:callback] 

	MODES = [LiveMode = 0, TestMode = 1]
	LANGUAGES = [LngENG = 'EN', LngGEO = 'KA']

  RESULTCODE_OK = 0
  RESULTCODE_DOUBLE = 1
  RESULTCODE_PROBLEM = -1
  RESULTCODE_NOT_FOUND = -2
  RESULTCODE_PARAMETER = -3

 	@mode = MODES[TestMode]

  def services
  end

  def index
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Pay::Payment
    if @search
      rel = rel.where(serviceid: @search[:serviceid].mongonize) if @search[:serviceid].present?
      rel = rel.where(clientname: @search[:clientname].mongonize) if @search[:clientname].present?
      rel = rel.where(ordercode: @search[:ordercode]) if @search[:ordercode].present?
      rel = rel.where(status: @search[:status]) if @search[:status].present?
      rel = rel.where(instatus: @search[:instatus]) if @search[:instatus].present?
      rel = rel.where(date: @search[:date]) if @search[:date].present?
    end

    set_status_from_billing(rel)

    @payments = rel.paginate(page: params[:page], per_page: 20)
  end

  def user_index
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Pay::Payment
    rel = rel.where(user: current_user)
    rel = rel.in(gstatus: [Pay::Payment::GSTATUS_OK, Pay::Payment::GSTATUS_PROCESS, Pay::Payment::GSTATUS_ERROR])
    if @search
      rel = rel.where(serviceid: @search[:serviceid].mongonize) if @search[:serviceid].present?
      rel = rel.where(ordercode: @search[:ordercode]) if @search[:ordercode].present?
      rel = rel.where(gstatus: @search[:gstatus]) if @search[:gstatus].present?
      rel = rel.where(date: @search[:date]) if @search[:date].present?
    end

    set_status_from_billing(rel)

    @payments = rel.paginate(page: params[:page], per_page: 20)
  end

  def show_form
    if request.post?
      @payment = Pay::Payment.new(
          user: current_user, 
          accnumb:    params[:pay_payment][:accnumb],
          rs_tin:     params[:pay_payment][:rs_tin],
          serviceid:  params[:pay_payment][:serviceid],
          merchant:   params[:pay_payment][:merchant],
          amount:     params[:pay_payment][:amount],
          clientname: params[:pay_payment][:clientname],
          testmode: Payge::TESTMODE, 
          ordercode: self.gen_order_code, currency: 'GEL', 
          lng: 'ka', ispreauth: 0, postpage: 0, gstatus: Pay::Payment::GSTATUS_SENT)

      @payment.generate_description
      @payment.prepare_for_step(Payge::STEP_SEND)
      @payment.user = current_user
      @payment.createdate = Time.now
      @payment.successurl = Payge::URLS[:success]
      @payment.cancelurl = Payge::URLS[:cancel]
      @payment.errorurl = Payge::URLS[:error]
      @payment.callbackurl = Payge::URLS[:callback]

      if @payment.save
        redirect_to pay_confirm_form_url(ordercode: @payment.ordercode)
      end

      params[:serviceid] = params[:pay_payment][:serviceid]
    else 
      if params[:accnumb]
        accnumb = params[:accnumb]
        rs_tin  = nil
      else
        default_registration = (current_user&&current_user.registrations[0]) || Customer::Registration.new
        accnumb = default_registration.customer.accnumb if default_registration.custkey.present?
        rs_tin  = default_registration.rs_tin
      end
      @payment = Pay::Payment.new(accnumb: accnumb, clientname: accnumb, rs_tin: rs_tin, amount: ( params[:amount] || 0 ), serviceid: params[:serviceid], merchant: get_current_merchant(params[:serviceid]) )
    end
  end

  def confirm_form
    @payment = Pay::Payment.where("ordercode" => params[:ordercode]).first
    if @payment.status  # if there is ordercode with populated status, this payment is completed or processing
      redirect_to pay_error_url
    end
  end

  def gen_order_code
    @seq = Pay::Sequence.find_and_modify( { "$inc" => { sequence: 1 } },
                                          { new: true }
                                          ) 
    if !@seq 
      @seq = Pay::Sequence.new

      @payment = Pay::Payment.where("merchant" => params[:pay_payment][:merchant]).sort([['ordercode', -1]]).first

      @seq.sequence = @payment.ordercode + 1 if @payment
      @seq.sequence = 1 unless @payment
      @seq.save
    end

    @seq["sequence"]
  end

  def success
    update_payment()
  end

  def cancel
    update_payment()
  end

  def error
    update_payment()
  end

  def callback
    @payment = Pay::Payment.where("ordercode" => params[:ordercode]).first

    if !@payment # if payment not found 
      @payment = Pay::Payment.new
      @payment.resultcode = RESULTCODE_NOT_FOUND
    else
      # exit if payment has OK status - save from if someone enters CALLBACK with parameters in browser
      if @payment.gstatus == ( Pay::Payment::GSTATUS_PROCESS or Pay::Payment::GSTATUS_OK )
        abort('error')
      end

      @payment.status = params[:status]
      @payment.check_callback = params[:check]
      @payment.transactioncode = params[:transactioncode]
      @payment.paymethod = params[:paymethod]
      @payment.twoid = params[:TWOID]

      # if payment successfully was sent and we recieved COMPLETED status
      if @payment.status == Pay::Payment::STATUS_COMPLETED # && @payment.instatus == Pay::Payment::INSTATUS_OK
        @payment.resultcode = RESULTCODE_OK
        @payment.gstatus = Pay::Payment::GSTATUS_PROCESS

        check_callback = @payment.prepare_for_step(Payge::STEP_CALLBACK)
        # check on callback CRC
        if check_callback != @payment.check_callback
          @payment.resultcode = RESULTCODE_PARAMETER
          @payment.instatus = Pay::Payment::INSTATUS_CAL_CHECK_ERROR
          @payment.gstatus = Pay::Payment::GSTATUS_ERROR
        else
          if not write_to_bs(@payment)
            @payment.gstatus = Pay::Payment::GSTATUS_ERROR_BILLING
            @payment.resultcode = RESULTCODE_PROBLEM
          end
        end

      else # payment was sent but something went wrong
        @payment.gstatus = Pay::Payment::GSTATUS_ERROR
        @payment.resultcode = RESULTCODE_PROBLEM
      end
      @payment.save
    end
    @payment.check_response = @payment.prepare_for_step(Payge::STEP_RESPONSE)
  end

  def update_payment
    @payment = Pay::Payment.where("ordercode" => params[:ordercode]).first
    
    if @payment

      @payment.status = params[:status]
      @payment.transactioncode = params[:transactioncode]
      @payment.date = DateTime.strptime(params[:date],'%Y%m%d%H%M%S')
      @payment.paymethod = params[:paymethod]
      @payment.check_returned = params[:check]

      case @payment.status 

       when Pay::Payment::STATUS_COMPLETED
         check_string = @payment.prepare_for_step(Payge::STEP_RETURNED)
         if check_string != @payment.check_returned
           @payment.instatus = Pay::Payment::INSTATUS_RET_CHECK_ERROR
           @payment.gstatus = Pay::Payment::GSTATUS_ERROR
           redirect_to pay_error_url
         else
          @payment.instatus = Pay::Payment::INSTATUS_OK
         end

       when Pay::Payment::STATUS_CANCELED
         @payment.gstatus = Pay::Payment::GSTATUS_CANCEL
         redirect_to pay_cancel_url

       when Pay::Payment::STATUS_ERROR
         @payment.gstatus = Pay::Payment::GSTATUS_ERROR
         redirect_to pay_error_url

      end

      @payment.save
    end
  end

  def write_to_bs(payment)
    case payment.serviceid
      when 'ENERGY'
        write_to_payment(payment)
      when 'TRASH'
        write_to_trash(payment)
      else
        true
    end
  end

  def write_to_payment(payment)
    customer = Billing::Customer.where(accnumb: @payment.accnumb).first
    @billing_payment = Billing::Payment.new
    @billing_payment.custkey = customer.custkey
    @billing_payment.billoperkey = Payge::BILLING_CONSTANTS[:billoperkey]
    @billing_payment.paytpkey = Payge::BILLING_CONSTANTS[:paytpkey]
    @billing_payment.ppointkey = Payge::BILLING_CONSTANTS[:ppointkey]
    @billing_payment.perskey = get_perskey(@payment.serviceid)
    @billing_payment.regionkey = Billing::Address.where(premisekey: customer.premisekey).first.regionkey
    @billing_payment.paydate = @payment.date || Time.now
    @billing_payment.amount = @payment.amount
    @billing_payment.billnumber = "#{@payment.transactioncode} Web"
    @billing_payment.status = Payge::BILLING_CONSTANTS[:status]
    @billing_payment.accnumb = @payment.accnumb
    @billing_payment.enterdate = @payment.date

    @billing_payment.save
  end

  def write_to_trash(payment)
    customer = Billing::Customer.where(accnumb: @payment.accnumb).first
    @trash_payment = Billing::TrashPayment.new
    @trash_payment.custkey = customer.custkey
    @trash_payment.operationid = Payge::BILLING_CONSTANTS[:billoperkey]
    @trash_payment.paytpkey = Payge::BILLING_CONSTANTS[:paytpkey]
    @trash_payment.ppointkey = Payge::BILLING_CONSTANTS[:ppointkey]
    @trash_payment.perskey = get_perskey(@payment.serviceid)
    @trash_payment.trashofficeid = Billing::Address.where(premisekey: customer.premisekey).first.regionkey
    @trash_payment.paydate = @payment.date || Time.now
    @trash_payment.amount = @payment.amount
    @trash_payment.billnumber = "#{@payment.transactioncode} Web"
    @trash_payment.status = Payge::BILLING_CONSTANTS[:status]
    @trash_payment.accnumb = @payment.accnumb
    @trash_payment.enterdate = @payment.date

    @trash_payment.save
  end

  def get_current_merchant(serviceid)
    Payge::PAY_SERVICES.find{ |h| h[:ServiceID] == serviceid }[:Merchant]
  end

  def get_perskey(serviceid)
    Payge::PAY_SERVICES.find{ |h| h[:ServiceID] == serviceid }[:perskey] rescue Payge::BILLING_CONSTANTS[:perskey]
  end  

  def delete_all
    Pay::Payment.delete_all
    redirect_to pay_url
  end

  def validate_users
    if not Payge::USERS.include?(current_user.email)
      redirect_to root_path
    end
  end

  def set_status_from_billing(rel)
    rel.all.select{ |r| r.transactioncode and r.gstatus == Pay::Payment::GSTATUS_PROCESS }.each do |rl|

    case rl.serviceid
      when 'ENERGY'
        pay = Billing::Payment.where(billnumber: "#{rl.transactioncode} Web").first
      when 'TRASH'
        pay = Billing::TrashPayment.where(billnumber: "#{rl.transactioncode} Web").first
    end
     
     if pay and pay.status == 2
       rl.gstatus = Pay::Payment::GSTATUS_OK
       rl.save
     end
    end
  end

end
