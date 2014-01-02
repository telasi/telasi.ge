# -*- encoding : utf-8 -*-
class NewCustomersController < ApplicationController
  before_action :validate_login

  def index
    @title = I18n.t('models.network_new_customer_application.actions.index_page.title')
    @applications = Network::NewCustomerApplication.where(user: current_user).desc(:_id).paginate(page: params[:page], per_page: 5)
    if Telasi::NEWCUSTAPP_UNDERCONSTRUCTION
      render 'under_construction' unless current_user.admin
    end
  end

  def new
    @title = I18n.t('models.network_new_customer_application.actions.new')
    user = current_user
    if request.post?
      @application = Network::NewCustomerApplication.new(application_params)
      @application.user = user
      @application.online = true
      if @application.save
        redirect_to new_customer_url(id: @application.id), notice: 'განცხადება შექმნილია'
      end
    else
      @application = Network::NewCustomerApplication.new(mobile: user.mobile, email: user.email)
    end
  end

  def show
    with_application do
      respond_to do |format|
        format.html { @title, @pill = I18n.t('applications.new_customer.general'), 'general' }
        format.pdf { render template: 'network/new_customer/print' }
      end
    end
  end

  def files
    with_application do
      @title, @pill = I18n.t('applications.new_customer.files'), 'files'
    end
  end

  def messages
    with_application do
      @title, @pill = I18n.t('applications.new_customer.messages'), 'messages'
    end
  end

  def items
    with_application do
      @title, @pill = I18n.t('applications.new_customer.items'), 'items'
    end
  end

  def edit
    with_application do
      @title = I18n.t('models.network_new_customer_application.actions.edit.title')
      if request.patch?
        if @application.update_attributes(application_params)
          redirect_to new_customer_url(id: @application.id)
        end
      end
    end
  end

  # def payments
  #   with_application do
  #     @title = I18n.t('models.network_new_customer_application.payments')
  #   end
  # end

  # def files
  #   with_application do
  #     @title = I18n.t('models.network_new_customer_application.actions.nav.files')
  #   end
  # end

  # def upload_file
  #   with_application do
  #     @title = I18n.t('models.network_new_customer_application.actions.upload')
  #     if request.post? and params[:sys_file]
  #       @file = Sys::File.new(params.require(:sys_file).permit(:file))
  #       if @file.save
  #         @application.files << @file
  #         redirect_to new_customer_files_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.upload_complete')
  #       end
  #     else
  #       @file = Sys::File.new
  #     end
  #   end
  # end

  # def delete_file
  #   with_application do
  #     file = @application.files.where(_id: params[:file_id]).first
  #     file.destroy
  #     redirect_to new_customer_files_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.delete_complete')
  #   end
  # end

  def nav
    @nav = { I18n.t('models.network_new_customer_application.actions.index_page.title') => new_customers_url }
    if @application
      if @application.new_record?
        @nav[I18n.t('models.network_new_customer_application.actions.new')] = create_new_customer_url
      else
        @nav["განცხადება ##{@application.effective_number}"] = new_customer_url(id: @application.id)
        @nav[@title] = nil unless action_name == 'show'
      end
    end
  end

  private

  def with_application
    @application = Network::NewCustomerApplication.where(user: current_user, _id: params[:id]).first
    if @application
      @nav = nav
      yield if block_given?
    else
      redirect_to new_customer_url, alert: 'not permitted'
    end
  end

  def application_params; params.require(:network_new_customer_application).permit(:rs_tin, :mobile, :email, :address, :bank_code, :bank_account, :work_address, :address_code, :bank_code, :bank_account, :power, :voltage) end
end
