# -*- encoding : utf-8 -*-
class Admin::CustomersController < ApplicationController
  def index
    @title = t('models.billing_customer_registration.title.pluaral')
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Customer::Registration
    if @search
      if @search[:customer_id].present?
        @search[:customer] = Billing::Customer.find(@search[:customer_id])
        rel = rel.where(custkey: @search[:customer].custkey)
      end
      rel = rel.where(rs_tin: @search[:rs_tin].mongonize) if @search[:rs_tin].present?
      rel = rel.where(rs_name: @search[:rs_name].mongonize) if @search[:rs_name].present?
      rel = rel.where(status: @search[:status].to_i) if @search[:status].present?
    end
    @registrations = rel.desc(:_id).paginate(page: params[:page], per_page: 20)
  end

  def show
    @title = 'რეგისტრაციის თვისებები'
    @registration = Customer::Registration.find(params[:id])
  end

  def confirm
    @registration = Billing::CustomerRegistration.find(params[:id])
    @registration.confirmed = true
    @registration.denied = false
    @registration.denial_reason = nil
    @registration.save
    send_sms(@registration, "Tqveni onlain motxovnis Sesabamisad, abonenti ##{@registration.customer.accnumb} dadasturebulia!")
    redirect_to admin_show_customer_url(id: @registration.id), notice: I18n.t('models.billing_customer_registration.actions.registration_confirmed')
  end

  def deny
    @title = I18n.t('models.billing_customer_registration.actions.deny_alt')
    @registration = Billing::CustomerRegistration.find(params[:id])
    if request.post?
      @registration.confirmed = false
      @registration.denied = true
      if @registration.update_attributes(params.require(:billing_customer_registration).permit(:denial_reason))
        send_sms(@registration, "abonenti ##{@registration.customer.accnumb} ar dagidasturdat, Semdegi mizezis gamo: #{@registration.denial_reason}")
        redirect_to admin_show_customer_url(id: @registration.id), notice: I18n.t('models.billing_customer_registration.actions.registration_denied')
      end
    end
  end

  def delete
    registration = Billing::CustomerRegistration.find(params[:id])
    registration.destroy
    redirect_to admin_customers_url, notice: 'რეგისტრაცია წაშლილია'
  end

  def nav
    @nav = { 'რეგისტრაციები' => admin_customers_url }
    if @registration
      @nav[@registration.customer.custname.to_ka] = admin_show_customer_url(id: @registration.id)
      @nav[@title] = nil unless action_name == 'show'
    end
  end

  private

  def send_sms(registration, text)
    Magti.send_sms(registration.user.mobile, text.to_lat) if Magti::SEND
  end
end
