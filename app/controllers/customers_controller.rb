# -*- encoding : utf-8 -*-
class CustomersController < ApplicationController
  def index
    if current_user
      @title = I18n.t('menu.customers')
      @registrations = Customer::Registration.where(user: current_user).asc(:_id)
    else
      redirect_to search_customer_url
    end
  end

  def search
    @title = I18n.t('models.billing_customer.actions.search')
    if params[:accnumb].present?
      customer=Billing::Customer.where(accnumb: params[:accnumb].to_lat).first
      redirect_to customer_info_url(custkey: customer.custkey) if customer
    end
  end

  def info
    @title = I18n.t('models.billing_customer.actions.info')
    @customer = Billing::Customer.find(params[:custkey])
    if request.post?
      @registration = Customer::Registration.new(customer_params)
      @registration.custkey = @customer.custkey
      @registration.user = current_user
      if @registration.save
        redirect_to customers_url, notice: I18n.t('models.customer_registration.actions.save_complete')
      end
    else
      @registration = Customer::Registration.new
    end
  end

  def remove
    registration = Customer::Registration.find(params[:id])
    registration.destroy
    redirect_to customers_url, notice: I18n.t('models.customer_registration.actions.remove_complete')
  end

  def edit
    @title = t('models.customer_registration.actions.edit')
    @registration = Customer::Registration.find(params[:id])
    if request.patch?
      if @registration.update_attributes(customer_params)
        redirect_to customer_registration_url(id:@registration.id), notice:t('models.customer_registration.actions.edit_complete')
      end
    end
  end

  def registration
    @title = t('pages.customers.registration.title')
    @registration = Customer::Registration.find(params[:id])
  end

  def registration_messages
    @title = t('pages.customers.registration.messages')
    @registration = Customer::Registration.find(params[:id])
  end

  def registration_docs
    @title = t('pages.customers.registration.documents')
    @registration = Customer::Registration.find(params[:id])
  end

  def registration_upload_doc
    @title = t('pages.customers.registration.add_file')
    @document = Customer::Document.find(params[:doc_id])
    @registration = @document.registration
    if request.post?
      @file = Sys::File.new(params.require(:sys_file).permit(:file))
      if @file.save
        @document.file = @file; @document.save
        redirect_to customer_registration_docs_url(id: @registration.id), notice: I18n.t('pages.customers.registration.doc_upload_complete')
      end
    else
      @file = Sys::File.new
    end
  end

  def resend
    registration = Customer::Registration.find(params[:id])
    registration.status = Customer::Registration::STATUS_START
    registration.save
    redirect_to customer_registration_url(id: registration.id), notice: t('pages.customers.register.resend_complete')
  end

  def toggle_sms
    registration=Customer::Registration.find(params[:id])
    registration.receive_sms=(!registration.receive_sms)
    registration.save
    redirect_to customers_url, notice: t('models.customer_registration.actions.toggle_sms_complete')
  end

  def history
    @title = I18n.t('models.billing_customer.actions.history')
    @registration = Customer::Registration.where(user: current_user, custkey: params[:custkey]).first
    if @registration
      @customer = @registration.customer
      @items = Billing::Item.where(customer: @customer).order('itemkey DESC').paginate(per_page: 15, page: params[:page])
    else
      redirect_to customers_url, notice: 'not allowed'
    end
  end

  def trash_history
    @title = I18n.t('models.billing_customer.actions.trash_history')
    @registration = Customer::Registration.where(user: current_user, custkey: params[:custkey]).first
    if @registration
      @customer = @registration.customer
      @items = Billing::TrashItem.where(customer: @customer).order('trashitemid DESC').paginate(per_page: 15, page: params[:page])
    else
      redirect_to customers_url, notice: 'not allowed'
    end
  end

  def nav
    @nav = { t('menu.customers') => customers_url }
    if @registration
      if not ['history','trash_history','info'].include?(action_name)
        @nav["#{t('pages.customers.registration.title')} ##{@registration.customer.accnumb.to_ka}"] = customer_registration_url(id: @registration.id)
        @nav[t('pages.customers.registration.documents')] = customer_registration_docs_url(id: @registration.id) if action_name == 'registration_upload_doc'
      end
      @nav[@title] = nil unless action_name == 'registration'
    end
    @nav
  end

  #bacho 15/08/2016
  def billpdf
    custkey_v= params[:custkey_p]
    payable_balance_v= params[:payable_balance_p]
    trash_balance_v= params[:trash_balance_p]
    current_water_balance_v= params[:current_water_balance_p]
    last_bill_date_v= params[:last_bill_date_p]
    last_bill_number_v= params[:last_bill_number_p]
    cut_deadline_v=params[:cut_deadline_p]
    accnumb_v= params[:accnumb_p]
    custname_v=params[:custname_p]
    t_balance_text_v=params[:t_balance_text_p]
    t_wbalance_text_v=params[:t_wbalance_text_p]
    t_tbalance_text_v=params[:t_tbalance_text_p]
    t_cut_deadline_v=params[:t_cut_deadline_p]
    t_bill_header_v=params[:t_bill_header_p]
    t_print_time_v=params[:t_print_time_p]
    t_accnumb_v=params[:t_accnumb_p]
    deposit_v=Billing::DepositCustomer.where(:custkey => custkey_v).where(:status => 0).last
    
    if !deposit_v.nil? 
      balance_v=balance_v.to_f+deposit_v.depozit_amount
    end

    respond_to do |format|
      format.html
      
      format.pdf do
        pdf = BillPdf.new( custkey_v , 
                           payable_balance_v ,
                           trash_balance_v , 
                           current_water_balance_v ,
                           last_bill_date_v, 
                           last_bill_number_v  ,
                           cut_deadline_v   ,
                           accnumb_v  ,
                           custname_v ,
                           t_balance_text_v ,
                           t_wbalance_text_v ,
                           t_tbalance_text_v ,
                           t_cut_deadline_v,
                           t_bill_header_v,
                           t_print_time_v,
                           t_accnumb_v
                          )

        send_data pdf.render , filename: 'Bill' , type: 'application/pdf' , disposition: 'inline'
      end  

    end  
  end

  private
  def customer_params; params.require(:customer_registration).permit(:category, :ownership, :rs_tin, :address, :address_code, :need_factura, :change_data, :bank_code, :bank_account) end
end
