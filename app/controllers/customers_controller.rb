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
      customer=Billing::Customer.active.where(accnumb: params[:accnumb].to_lat).first
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

  private
  def customer_params; params.require(:customer_registration).permit(:category, :ownership, :rs_tin, :address, :address_code, :need_factura, :change_data, :bank_code, :bank_account) end
end
