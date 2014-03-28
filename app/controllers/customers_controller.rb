# -*- encoding : utf-8 -*-
class CustomersController < ApplicationController
  def index
    @title = I18n.t('menu.customers')
    @registrations = Customer::Registration.where(user: current_user).asc(:_id)
  end

  def search
    @title = I18n.t('models.billing_customer.actions.search')
    if params[:accnumb].present?
      customer = Billing::Customer.where(accnumb: params[:accnumb].to_lat).first
      redirect_to customer_info_url(custkey: customer.custkey) if customer
    end
  end

  def info
    @title = I18n.t('models.billing_customer.actions.info')
    @customer = Billing::Customer.find(params[:custkey])
    if request.post?
      @registration = Customer::Registration.new(params.require(:customer_registration).permit(:category, :ownership, :rs_tin, :address, :address_code))
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

  def registration
    @title = t('pages.customers.registration.title')
    @registration = Customer::Registration.find(params[:id])
  end

  def registration_docs
    @title = t('pages.customers.registration.documents')
    @registration = Customer::Registration.find(params[:id])
  end

  def registration_messages
    @title = t('pages.customers.registration.messages')
    @registration = Customer::Registration.find(params[:id])
  end

  # def history
  #   @title = I18n.t('models.billing_customer.actions.history')
  #   @registration = Billing::CustomerRegistration.where(user: current_user, custkey: params[:custkey]).first
  #   if @registration
  #     @customer = @registration.customer
  #     @items = Billing::Item.where(customer: @customer).order('itemkey DESC').paginate(per_page: 10, page: params[:page])
  #   else
  #     redirect_to customers_url, notice: 'not allowed'
  #   end
  # end

  # def trash_history
  #   @title = I18n.t('models.billing_customer.actions.trash_history')
  #   @registration = Billing::CustomerRegistration.where(user: current_user, custkey: params[:custkey]).first
  #   if @registration
  #     @customer = @registration.customer
  #     @items = Billing::TrashItem.where(customer: @customer).order('trashitemid DESC').paginate(per_page: 10, page: params[:page])
  #   else
  #     redirect_to customers_url, notice: 'not allowed'
  #   end
  # end

  def nav
    @nav = { t('menu.customers') => customers_url }
    if @registration
      @nav[t('pages.customers.registration.title')] = customer_registration_url(id: @registration.id)
    end
    @nav
  end
end
