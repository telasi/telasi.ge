# -*- encoding : utf-8 -*-
class Admin::CustomerDoctypesController < ApplicationController
  def index
    @title = t('pages.admin.customers.document_type.title')
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Customer::DocumentType
    if @search
      rel = rel.where(category: @search[:category]) if @search[:category].present?
      rel = rel.where(ownership: @search[:ownership]) if @search[:ownership].present?
    end
    @doctypes = rel.paginate(page: params[:page], per_page: 100)
  end

  def show
    @title = t('pages.admin.customers.document_type.show_doctype')
    @doctype = Customer::DocumentType.find(params[:id])
  end

  def new
    @title = t('pages.admin.customers.document_type.new_doctype')
    if request.post?
      @doctype = Customer::DocumentType.new(doctype_params)
      if @doctype.save
        redirect_to admin_customer_doctypes_url, notice: 'სახეობა დამატებულია'
      end
    else
      @doctype = Customer::DocumentType.new
    end
  end

  def edit
    @title = t('pages.admin.customers.document_type.edit_doctype')
    @doctype = Customer::DocumentType.find(params[:id])
    if request.post?
      if @doctype.update_attributes(doctype_params)
        redirect_to admin_customer_doctype_url(id: @doctype.id), notice: 'სახეობა შეცვლილია'
      end
    end
  end

  def delete
    doctype = Customer::DocumentType.find(params[:id])
    doctype.destroy
    redirect_to admin_customer_doctypes_url, notice: 'სახეობა წაშლილია'
  end

  def nav
    @nav = {
      'რეგისტრაციები' => admin_customers_url,
      t('pages.admin.customers.document_type.title') => admin_customer_doctypes_url
    }
    if @doctype
      @nav[@doctype.name] = admin_customer_doctype_url(id: @doctype.id) unless @doctype.new_record?
      @nav[@title] = nil unless action_name == 'show'
    end
  end

  private

  def doctype_params; params.require(:customer_document_type).permit(:name_ka,:name_ru,:ownership,:category,:required) end
end
