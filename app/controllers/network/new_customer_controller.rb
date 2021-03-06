# -*- encoding : utf-8 -*-
require 'rs'
require 'rest_client'
require 'will_paginate/array'

class Network::NewCustomerController < ApplicationController
  include Sys::BackgroundJobConstants

  def self.filter_applications(search)
    rel = Network::NewCustomerApplication
    if search
      rel = rel.where(number: search[:number].mongonize) if search[:number].present?
      rel = rel.where(rs_name: search[:rs_name].mongonize) if search[:rs_name].present?
      rel = rel.where(rs_tin: search[:rs_tin].mongonize) if search[:rs_tin].present?
      rel = rel.where(address_code: search[:address_code].mongonize) if search[:address_code].present?
      rel = rel.where(address: search[:address].mongonize) if search[:address].present?
      rel = rel.where(work_address: search[:work_address].mongonize) if search[:work_address].present?
      rel = rel.where(status: search[:status].to_i) if search[:status].present?
      rel = rel.where(stage: Network::Stage.find(search[:stage])) if search[:stage].present?
      rel = rel.where(online: search[:online] == 'yes') if search[:online].present?
      rel = rel.where(:send_date.gte => search[:send_d1]) if search[:send_d1].present?
      rel = rel.where(:send_date.lte => search[:send_d2]) if search[:send_d2].present?
      rel = rel.where(:start_date.gte => search[:start_d1]) if search[:start_d1].present?
      rel = rel.where(:start_date.lte => search[:start_d2]) if search[:start_d2].present?
      rel = rel.where(:production_date.gte => search[:production_d1]) if search[:production_d1].present?
      rel = rel.where(:production_date.lte => search[:production_d2]) if search[:production_d2].present?
      rel = rel.where(:plan_end_date.gte => search[:plan_d1]) if search[:plan_d1].present?
      rel = rel.where(:plan_end_date.lte => search[:plan_d2]) if search[:plan_d2].present?
      rel = rel.where(:end_date.gte => search[:real_d1]) if search[:real_d1].present?
      rel = rel.where(:end_date.lte => search[:real_d2]) if search[:real_d2].present?
      rel = rel.where(voltage: search[:voltage]) if search[:voltage].present?
      rel = rel.where(:power.gte => search[:power1]) if search[:power1].present? and search[:power1].to_f >= 0
      rel = rel.where(:power.lte => search[:power2]) if search[:power2].present? and search[:power1].to_f >= 0
      rel = rel.where(proeqti: search[:proeqti].mongonize) if search[:proeqti].present?
      rel = rel.where(oqmi: search[:oqmi].mongonize) if search[:oqmi].present?
      rel = rel.where(factura_seria: search[:factura_seria]) if search[:factura_seria].present?
      rel = rel.where(factura_number: search[:factura_number].to_i) if search[:factura_number].present?
      rel = rel.where(personal_use: search[:personal_use]) if search[:personal_use].present?
      rel = rel.where(user: Sys::User.where(email: search[:user]).first) if search[:user].present?
      rel = rel.where(:created_at.gte => search[:created_at_d1]) if search[:created_at_d1].present?
      rel = rel.where(:created_at.lte => search[:created_at_d2]) if search[:created_at_d2].present?
      if search[:customer_id].present?
        rel = rel.where(customer_id: nil) if search[:customer_id] == 'no'
        rel = rel.where(:customer_id.ne => nil) if search[:customer_id] == 'yes'
      end
      if search[:accnumb].present?
        cust = Billing::Customer.where(accnumb: search[:accnumb].strip.to_lat).first
        rel = rel.where(customer_id: cust.custkey) if cust.present?
      end
      if search[:penalty].present?
        rel = rel.where(:status.in => [Network::NewCustomerApplication::STATUS_COMPLETE, Network::NewCustomerApplication::STATUS_IN_BS])
        case search[:penalty]
        when '0' then rel = rel.where(:penalty1    => 0, :penalty2 => 0, :penalty3 => 0)
        when '1' then rel = rel.where(:penalty1.gt => 0, :penalty2 => 0, :penalty3 => 0)
        when '2' then rel = rel.where(:penalty2.gt => 0, :penalty3 => 0)
        when '3' then rel = rel.where(:penalty3.gt => 0)
        end
      end
    end
    rel
  end

  def prepayment_report
    rel = Network::NewCustomerApplication.where(:status.in => [ Network::NewCustomerApplication::STATUS_DEFAULT, 
                                                                Network::NewCustomerApplication::STATUS_SENT, 
                                                                Network::NewCustomerApplication::STATUS_CONFIRMED ],
                                                need_factura: true)
    rel = rel.where(factura_id: nil)
    rel = rel.where(:send_date.gte => Network::PREPAYMENT_START_DATE)

    @search = params[:search] == 'clear' ? nil : params[:search]
    
    if @search
      if @search[:type].present?
        case @search[:type]
         when '1'
          rel = rel.where(:customer_id.ne => nil)
         when '2'
          rel = rel.where(customer_id: nil)        
        end
      end

      if @search[:deadline].present?
        case @search[:deadline]
         when '1'
          rel = rel.where(:send_date.lte => Time.now - 5.days)
         when '2'
          rel = rel.or({ :send_date.gt => Time.now - 5.days}, { send_date: nil })
        end
      end

    end

    rel = rel.select{ |x| x.billing_prepayment_to_factured.where('itemdate >= ?', Network::PREPAYMENT_START_DATE).present? }
    @applications = rel.paginate(per_page: 3000)
  end

  def accounting_report
    @title = 'უწყისი'
    @search = params[:search] == 'clear' ? nil : params[:search]
    rel = Network::NewCustomerController.filter_applications(@search)
    respond_to do |format|
      format.html { @applications = rel.desc(:_id).paginate(page: params[:page_new], per_page: 10) }
      format.xlsx do
        @applications = rel.desc(:_id).paginate(per_page: 50000)
      end
    end
  end

  def index
    @title = I18n.t('models.network_new_customer_item.actions.new_account')
    @search = params[:search] == 'clear' ? nil : params[:search]
    rel = Network::NewCustomerController.filter_applications(@search)
    respond_to do |format|
      format.html { @applications = rel.desc(:_id).paginate(page: params[:page_new], per_page: 10) }
      format.xlsx do
        # job = Sys::BackgroundJob.perform(user:current_user, name: NETWORK_NEWCUSTOMER_TO_XLSX, data: params[:search].to_s)
        # redirect_to network_printing_new_customer_url(jobid: job.id, return_url: network_new_customers_url(search: params[:search]))
        @applications = rel.desc(:_id).paginate(per_page: 50000)
      end
    end
  end

  def printing
    @title = 'ბეჭდვა ...'
    @job = Sys::BackgroundJob.find(params[:jobid])
    @return_url = params[:return_url]
    render action: '../../layouts/background_job' #, formats: ['html'], content_type: 'text/html'
  end

  def new_customer
    @title = 'განცხადების თვისებები'
    @application = Network::NewCustomerApplication.find(params[:id])
  end

  def add_new_customer
    @title = I18n.t('models.network_new_customer_application.actions.new')
    if request.post?
      @application = Network::NewCustomerApplication.new(new_customer_params)
      @application.user = current_user
      # @application.status = Network::NewCustomerApplication::STATUS_SENT
      if @application.save
        redirect_to network_new_customer_url(id: @application._id, tab: 'general'), notice: I18n.t('models.network_new_customer_application.actions.added')
      end
    else
      @application = Network::NewCustomerApplication.new
    end
  end

  def edit_new_customer
    @title = I18n.t('models.network_new_customer_application.actions.edit.title')
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(new_customer_params)
        redirect_to network_new_customer_url(id: @application._id, tab: 'general'), notice: I18n.t('models.network_new_customer_application.actions.edit.changed')
      end
    end
  end

  # def postpone 
  #   @title = I18n.t('models.network_new_customer_application.actions.edit.title')
  #   @application = Network::NewCustomerApplication.find(params[:id])
  #   if request.post? and postpone_params[:postpone_file]
  #     p = params.require(:network_new_customer_application).permit(:postpone_file)
  #     p[:file] = p[:postpone_file]
  #     p.delete("postpone_file")
  #     @application.postpone_file = Sys::File.new(p)
  #     if @application.save
  #       if @application.update_attributes(postpone_params.except(:postpone_file))
  #         redirect_to network_new_customer_url(id: @application._id, tab: 'general'), notice: I18n.t('models.network_new_customer_application.actions.edit.changed')
  #       end
  #     end
  #   else
  #     @application.postpone_file = Sys::File.new
  #   end
  # end

  def delete_new_customer
    application = Network::NewCustomerApplication.find(params[:id])
    application.destroy
    redirect_to network_home_url, notice: I18n.t('models.network_new_customer_application.actions.edit.deleted')
  end

  def link_bs_customer
    @title = 'აბონენტის დაკავშირება'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @application.link_bs_customer!(params.require(:network_new_customer_application).permit(:customer_id))
      #@application.update_attributes(params.require(:network_new_customer_application).permit(:customer_id))
      redirect_to network_new_customer_url(id: @application.id, tab: 'accounts')
    end
  end

  def remove_bs_customer
    application = Network::NewCustomerApplication.find(params[:id])
    application.remove_bs_customer!
    # application.customer_id = nil
    # application.save
    redirect_to network_new_customer_url(id: application.id, tab: 'accounts')
  end

  def send_to_bs
    application = Network::NewCustomerApplication.find(params[:id])
    application.send_to_bs!
    redirect_to network_new_customer_url(id: application.id, tab: 'general'), notice: 'დარიცხვა გაგზავნილია ბილინგში'
  end

  def change_status
    @title = I18n.t('models.network_new_customer_application.actions.status.title')
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      if params[:sys_sms_message].present?
        @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
        @message.messageable = @application
        @message.mobile = @application.mobile
        if @message.save
          @message.send_sms!(lat: true)
        end
      end
      old_status = @application.status
      @application.status = params[:status].to_i
      if @application.save
        if @application.status==Network::NewCustomerApplication::STATUS_COMPLETE
          @application.message_to_gnerc(@message) if old_status != @application.status && @message.present?
          redirect_to network_change_dates_url(id: @application.id), alert: 'შეამოწმეთ განცხადების თარიღების სისწორე!'
        else
          redirect_to network_new_customer_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.status.changed')
        end
      else
        @error = @application.errors.full_messages
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def send_sms
    @title = I18n.t('models.network_new_customer_application.actions.message.title')
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
      @message.messageable = @application
      @message.mobile = @application.mobile
      if @message.save
        @message.send_sms!(lat: true)
        redirect_to network_new_customer_url(id: @application.id, tab: 'sms'), notice: I18n.t('models.network_new_customer_application.actions.message.sent')
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def upload_file
    @title = I18n.t('models.network_new_customer_application.actions.file.title')
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post? and params[:sys_file]
      @file = Sys::File.new(params.require(:sys_file).permit(:file))
      if @file.save
        @application.files << @file
        redirect_to network_new_customer_url(id: @application.id, tab: 'files'), notice: I18n.t('models.network_new_customer_application.actions.file.loaded')
      end
    else
      @file = Sys::File.new
    end
  end

  def delete_file
    application = Network::NewCustomerApplication.find(params[:id])
    file = application.files.where(_id: params[:file_id]).first
    file.destroy
    redirect_to network_new_customer_url(id: application.id, tab: 'files'), notice: I18n.t('models.network_new_customer_application.actions.file.deleted')
  end

  def change_dates
    @title = 'თარიღების შეცვლა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(params.require(:network_new_customer_application).permit(:send_date, :end_date ))#, :start_date))
        redirect_to network_new_customer_url(id: @application.id), notice: 'თარიღები შეცვლილია'
      end
    end
  end

  def sync_customers
    application = Network::NewCustomerApplication.find(params[:id])
    application.sync_customers!
    redirect_to network_new_customer_url(id: application.id, tab: 'accounts'), notice: 'სინქრონიზაცია დასრულებულია'
  end

  def paybill
    @application = @app = Network::NewCustomerApplication.find(params[:id])
    respond_to do |format|
      format.html do
        @title = I18n.t('applications.pay_order')
        @data = { amount: @app.amount / 2.0 }
      end
      format.pdf do
        amount = params[:amount].to_f rescue @app.amount / 2.0
        @data = { date: Date.today,
          payer: @app.rs_name, payer_account: @app.bank_account, payer_bank: @app.bank_name, payer_bank_code: @app.bank_code,
          receiver: 'სს თელასი', receiver_account: 'GE53TB1147136030100001  ', receiver_bank: 'სს თიბისი ბანკი',
          receiver_bank_code: 'TBCBGE22',
          reason: "სს თელასის განამაწილებელ ქსელში ჩართვის ღირებულების 50%-ის დაფარვა. განცხადება №#{@app.effective_number}; TAXID: #{@app.rs_tin}.",
          amount: amount
        }
      end
    end
  end

  # def print; @application = Network::NewCustomerApplication.find(params[:id]) end

  def print
    @application = Network::NewCustomerApplication.find(params[:id]) 
    send_data(Network::NewCustomerApplicationTemplate.new(@application).print, :filename => @application.id.to_s + 'pdf', :type => 'application/pdf', :disposition => 'inline') 
  end

  def print_cost_form
    @application = Network::NewCustomerApplication.find(params[:id]) 
    send_data(Network::NewCustomerApplicationTemplate.new(@application).print_cost_form, :filename => @application.id.to_s + 'pdf', :type => 'application/pdf', :disposition => 'inline') 
  end

  def sign
    @application = Network::NewCustomerApplication.find(params[:id])

    if request.post? 
      @application.signed = true
      @application.save
    else
      #binary = render_to_string 'print', formats: ['pdf']
      binary = Network::NewCustomerApplicationTemplate.new(@application).print
      name = "NewCustomer_#{params[:id]}.pdf"
      workstepId = Sys::Signature.send("newcustomer", name, binary, params[:id])
      url = Sys::Signature::WORKSTEP_SIGN
      redirect_to "#{url}#{workstepId}"
    end

  end

  def send_prepayment_factura_prepare
    @application = Network::NewCustomerApplication.find(params[:id])
    @items_to_factured = @application.billing_prepayment_to_factured
    # @items_to_factured = @application.billing_prepayment_chosen_to_factured
    @items = @application.billing_items_raw_to_factured
  end

  def send_prepayment_factura
    application = Network::NewCustomerApplication.find(params[:id])
    application.send_prepayment_facturas!(params[:chosen])
    redirect_to network_new_customer_url(id: application.id, tab: 'factura'), notice: 'ფაქტურა გაგზავნილია :)'
  end

  def send_factura
    application = Network::NewCustomerApplication.find(params[:id])
    raise 'ფაქტურის გაგზავნა დაუშვებელია' unless application.can_send_factura?
    # raise 'არსებობს ავანსი ფაქტურის გარეშე' if application.billing_prepayment_to_factured.present?
    # factura = RS::Factura.new(date: Time.now, seller_id: RS::TELASI_PAYER_ID)
    factura = RS::Factura.new(date: application.end_date, seller_id: RS::TELASI_PAYER_ID)
    good_name = "ქსელზე მიერთების პაკეტის ღირებულება #{application.number}"
    amount = application.effective_amount
    raise 'თანხა უნდა იყოს > 0' unless amount > 0
    raise 'ფაქტურის გაგზავნა ვერ ხერხდება!' unless RS.save_factura(factura, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, buyer_tin: application.rs_tin))
    vat = application.pays_non_zero_vat? ? amount * (1 - 1.0 / 1.18) : 0
    factura_item = RS::FacturaItem.new(factura: factura,
      good: good_name, unit: 'მომსახურეობა', amount: amount, vat: vat,
      quantity: 0)
    RS.save_factura_item(factura_item, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID))
    if RS.send_factura(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))
      factura = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))
      application.factura_seria = factura.seria
      application.factura_number = factura.number

      application.factura_id = factura.id
      application.save
      application.send_factura!(factura, amount)
    end

    redirect_to network_new_customer_url(id: application.id, tab: 'factura'), notice: 'ფაქტურა გაგზავნილია :)'
  end

  def send_correcting1_factura
    application = Network::NewCustomerApplication.find(params[:id])
    raise 'ფაქტურის გაგზავნა დაუშვებელია' unless application.can_send_correcting1_factura?

    application.correct_factures
    redirect_to network_new_customer_url(id: application.id, tab: 'factura'), notice: 'კორექტირების ფაქტურა გაგზავნილია'
  end

  def send_correcting2_factura
    application = Network::NewCustomerApplication.find(params[:id])
    raise 'ფაქტურის გაგზავნა დაუშვებელია' unless application.can_send_correcting2_factura?

    application.correct_factures
    redirect_to network_new_customer_url(id: application.id, tab: 'factura'), notice: 'კორექტირების ფაქტურა გაგზავნილია'
  end

  def new_control_item
    @title = I18n.t('models.network_new_customer_application.actions.control.title')
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @item = Network::RequestItem.new(params.require(:network_request_item).permit(:type, :date, :description, :stage_id))
      @item.source = @application
      if @item.save
        @application.update_last_request
        redirect_to network_new_customer_url(id: @application.id, tab: 'watch'), notice: I18n.t('models.network_new_customer_application.actions.control.added')
      end
    else
      @item = Network::RequestItem.new(source: @application, date: Date.today)
    end
  end

  def edit_control_item
    @title = I18n.t('models.network_new_customer_application.actions.control.change')
    @item = Network::RequestItem.find(params[:id])
    if request.post?
      if @item.update_attributes(params.require(:network_request_item).permit(:type, :date, :description, :stage_id))
        @item.source.update_last_request
        redirect_to network_new_customer_url(id: @item.source.id, tab: 'watch'), notice: I18n.t('models.network_new_customer_application.actions.control.changed')
      end
    end
  end

  def delete_control_item
    item = Network::RequestItem.find(params[:id])
    app = item.source
    item.destroy
    app.update_last_request
    redirect_to network_new_customer_url(id: app.id, tab: 'watch'), notice: I18n.t('models.network_new_customer_application.actions.control.deleted')
  end

  def toggle_need_factura
    application = Network::NewCustomerApplication.find(params[:id])
    application.need_factura = (not application.need_factura)
    application.save
    redirect_to network_new_customer_url(id: application.id), notice: 'სჭირდება ფაქტურა შეცვლილია'
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'ახალი აბონენტი' => network_new_customers_url }
    if @application
      if not @application.new_record?
        @nav[ "№#{@application.effective_number}" ] = network_new_customer_url(id: @application.id)
        @nav[@title] = nil if action_name != 'new_customer'
      else
        @nav['ახალი განცხადება'] = nil
      end
    end
    @nav
  end

  def new_overdue_item
    @title = I18n.t('models.network_new_customer_application.actions.control.title')
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @item = Network::OverdueItem.new(overdue_params)
      @item.source = @application
      if @item.save
        redirect_to network_new_customer_url(id: @application.id, tab: 'overdue'), notice: I18n.t('models.network_new_customer_application.actions.overdue.added')
      end
    else
      @item = Network::OverdueItem.new(source: @application, authority: 28, business_days: true)
    end
  end

  def edit_overdue_item
    @title = I18n.t('models.network_new_customer_application.actions.control.change')
    @item = Network::OverdueItem.find(params[:id])
    if request.post?
      if @item.update_attributes(overdue_params)
        redirect_to network_new_customer_url(id: @item.source.id, tab: 'overdue'), notice: I18n.t('models.network_new_customer_application.actions.overdue.changed')
      end
    end
  end

  def delete_overdue_item
    item = Network::OverdueItem.find(params[:id])
    app = item.source
    item.destroy
    redirect_to network_new_customer_url(id: app.id, tab: 'overdue'), notice: I18n.t('models.network_new_customer_application.actions.overdue.deleted')
  end

  def toggle_chose_overdue
    overdue = Network::OverdueItem.find(params[:id])
    overdue.chosen = (not overdue.chosen)
    overdue.save
    redirect_to network_new_customer_url(id: overdue.source.id, tab: 'overdue')
  end

  # def add_operation
  #   application = Network::NewCustomerApplication.find(params[:id])
  #   application.add_operation!(params[:itemkey])
  #   redirect_to network_new_customer_url(id: application.id, tab: 'advance')
  # end

  # def remove_operation
  #   application = Network::NewCustomerApplication.find(params[:id])
  #   application.remove_operation!(params[:itemkey])
  #   redirect_to network_new_customer_url(id: application.id, tab: 'advance')
  # end

  def edit_real_date
    @title = 'რეალური თარიღის შეცვლა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(params.require(:network_new_customer_application).permit(:real_end_date))
        redirect_to network_change_power_url(id: @application.id), notice: 'რეალური თარიღი შეცვლილია'
      end
    end
  end

  private

  def new_customer_params
    params.require(:network_new_customer_application).permit(:base_type, :base_number, :type, :customer_type_id, :number, :rs_tin, :rs_foreigner, :rs_name, :personal_use, :mobile, :email, :region, :address, :work_address, :address_code, :bank_code, :bank_account, :duration, :voltage, :power, :abonent_amount, :vat_options, :need_factura, :show_tin_on_print, :notes, :proeqti, :oqmi, :micro, :micro_voltage, :micro_power, :micro_power_source, :substation, :mtnumb)
  end

  def overdue_params
    params.require(:network_overdue_item).permit(:authority, :appeal_date, :planned_days, :deadline, :response_date, :decision_date, :days, :chosen, :business_days, :check_days)
  end

  def account_params; params.require(:network_new_customer_item).permit(:address, :address_code, :rs_tin, :customer_id) end
end
