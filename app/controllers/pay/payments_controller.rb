# -*- encoding : utf-8 -*-
class Pay::PaymentsController < ApplicationController
  before_action :validate_login

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

    @payments = rel.paginate(page: params[:page], per_page: 20)
  end

  def user_index
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Pay::Payment
    rel = rel.where(user: current_user)
    if @search
      rel = rel.where(serviceid: @search[:serviceid].mongonize) if @search[:serviceid].present?
      rel = rel.where(ordercode: @search[:ordercode]) if @search[:ordercode].present?
      rel = rel.where(gstatus: @search[:gstatus]) if @search[:gstatus].present?
      rel = rel.where(date: @search[:date]) if @search[:date].present?
    end

    @payments = rel.paginate(page: params[:page], per_page: 20)
  end

  def show_form
    if request.post?
      @payment = Pay::Payment.new(
          user: current_user, 
          #user: "current_user", 
          serviceid: params[:pay_payment][:serviceid],
          merchant: params[:pay_payment][:merchant],
          testmode: Payge::TESTMODE, 
          ordercode: self.gen_order_code, currency: 'GEL', amount: params[:pay_payment][:amount],
          description: 'test payment', lng: 'ka', ispreauth: 0, postpage: 0, gstatus: Pay::Payment::GSTATUS_SENT)

      @payment.prepare_for_step(Payge::STEP_SEND)
      @payment.user = current_user
      @payment.successurl = Payge::URLS[:success]
      @payment.cancelurl = Payge::URLS[:cancel]
      @payment.errorurl = Payge::URLS[:error]
      @payment.callbackurl = Payge::URLS[:callback]

      if @payment.save
        redirect_to pay_confirm_form_url(ordercode: @payment.ordercode)
      end

      params[:serviceid] = params[:pay_payment][:serviceid]

    else 
      @payment = Pay::Payment.new(amount: 100, serviceid: params[:serviceid], merchant: get_current_merchant(params[:serviceid]) )
    end
  end

  def confirm_form
    @payment = Pay::Payment.where("ordercode" => params[:ordercode]).first
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

  def gen_description_text
    'test payment'
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

    if !@payment
      @payment = Pay::Payment.new
      @payment.resultcode = RESULTCODE_NOT_FOUND
    else
      @payment.status = params[:status]
      @payment.check_callback = params[:check]

      if @payment.status == Pay::Payment::STATUS_COMPLETED && @payment.instatus == Pay::Payment::INSTATUS_OK
        @payment.resultcode = RESULTCODE_OK
        @payment.gstatus = Pay::Payment::GSTATUS_OK

        check_callback = @payment.prepare_for_step(Payge::STEP_CALLBACK)
        if check_callback != @payment.check_callback
          @payment.resultcode = RESULTCODE_PROBLEM 
          @payment.instatus = Pay::Payment::INSTATUS_CAL_CHECK_ERROR
          @payment.gstatus = Pay::Payment::GSTATUS_ERROR
        end

      else
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
         check_string = @payment.prepare_for_step(Pay::STEP_RETURNED)
         if check_string != @payment.check_returned
           @payment.instatus = Pay::Payment::INSTATUS_RET_CHECK_ERROR
           @payment.gstatus = Pay::Payment::GSTATUS_ERROR
           redirect_to pay_error_url
         else
          @payment.instatus = Pay::Payment::INSTATUS_OK
         end

       when Pay::Payment::STATUS_CANCELED
         @payment.gstatus = Pay::Payment::GSTATUS_ERROR
         redirect_to pay_cancel_url

       when Pay::Payment::STATUS_ERROR
         @payment.gstatus = Pay::Payment::GSTATUS_ERROR
         redirect_to pay_error_url

      end

      @payment.save
    end
  end

  def get_current_merchant(serviceid)
    Payge::PAY_SERVICES.find{ |h| h[:ServiceID] == serviceid }[:Merchant]
  end

  def delete_all
    Pay::Payment.delete_all
    redirect_to pay_url
  end

end