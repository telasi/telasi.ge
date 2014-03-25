# -*- encoding : utf-8 -*-
class Admin::CustomerDoctypesController < ApplicationController
  def index
    @title = t('models.billing_customer_registration.title.pluaral')
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Customer::DocumentType
    # if @search
    #   if @search[:customer_id].present?
    #     @search[:customer] = Billing::Customer.find(@search[:customer_id])
    #     rel = rel.where(custkey: @search[:customer].custkey)
    #   end
    #   rel = rel.where(rs_tin: @search[:rs_tin].mongonize) if @search[:rs_tin].present?
    #   rel = rel.where(rs_name: @search[:rs_name].mongonize) if @search[:rs_name].present?
    #   rel = rel.where(confirmed: @search[:confirmed] == 'yes') if @search[:confirmed].present?
    #   rel = rel.where(denied: @search[:denied] == 'yes') if @search[:denied].present?
    # end
    @doctypes = rel.paginate(page: params[:page], per_page: 100)
  end

  def show
    @title = I18n.t('pages.admin.customers.document_type.title')
    @registration = Billing::CustomerRegistration.find(params[:id])
  end

  def nav
    @nav = {
      'რეგისტრაციები' => admin_customers_url,
      I18n.t('pages.admin.customers.document_type.title') => admin_customer_doctypes_url
    }
    # if @registration
    #   @nav[@registration.customer.custname.to_ka] = admin_show_customer_url(id: @registration.id)
    #   @nav[@title] = nil unless action_name == 'show'
    # end
  end
end
