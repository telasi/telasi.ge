# -*- encoding : utf-8 -*-
class CustomersController < ApplicationController
  def index
    @title = I18n.t('menu.customers')
    @registrations = Billing::CustomerRegistration.where(user: current_user, denied: false).desc(:_id)
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
      @registration = Billing::CustomerRegistration.new(params.require(:billing_customer_registration).permit(:rs_tin, :dob))
      @registration.custkey = @customer.custkey
      @registration.user = current_user
      @registration.confirmed = false
      @registration.denied = false
      if @registration.save
        redirect_to add_customer_complete_url
      end
    else
      @registration = Billing::CustomerRegistration.new
    end
  end

  def complete; @title = I18n.t('models.billing_customer_registration.actions.add_complete') end

  def remove
    registration = Billing::CustomerRegistration.find(params[:id])
    registration.destroy
    redirect_to customers_url, notice: I18n.t('models.billing_customer_registration.actions.remove_complete')
  end

  def history
    @title = I18n.t('models.billing_customer.actions.history')
    @registration = Billing::CustomerRegistration.where(user: current_user, custkey: params[:custkey]).first
    if @registration
      @customer = @registration.customer
      @items = Billing::Item.where(customer: @customer).order('itemkey DESC').paginate(per_page: 10, page: params[:page])
    else
      redirect_to customers_url, notice: 'not allowed'
    end
  end

  def trash_history
    @title = I18n.t('models.billing_customer.actions.trash_history')
    @registration = Billing::CustomerRegistration.where(user: current_user, custkey: params[:custkey]).first
    if @registration
      @customer = @registration.customer
      @items = Billing::TrashItem.where(customer: @customer).order('trashitemid DESC').paginate(per_page: 10, page: params[:page])
    else
      redirect_to customers_url, notice: 'not allowed'
    end
  end
end
