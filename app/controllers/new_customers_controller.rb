# -*- encoding : utf-8 -*-
class NewCustomersController < ApplicationController
  def index
    @title = I18n.t('models.network_new_customer_application.actions.index_page.title')
    @applications = Network::NewCustomerApplication.where(user: current_user).desc(:_id).paginate(page: params[:page], per_page: 5)
  end

  def new
    @title = I18n.t('models.network_new_customer_application.actions.new')
    user = current_user
    if request.post?
      @application = Network::NewCustomerApplication.new(application_params)
      @application.user = user
      @application.online = true
      if @application.save
        redirect_to new_customer_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.created')
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

  def paybill
    with_application do
      @app = @application
      respond_to do |format|
        format.pdf {
          amount = @app.amount / 2.0
          @data = { date: Date.today,
            payer: @app.rs_name, payer_account: @app.bank_account, payer_bank: @app.bank_name, payer_bank_code: @app.bank_code,
            receiver: 'სს თელასი', receiver_account: 'GE53TB1147136030100001  ', receiver_bank: 'სს თიბისი ბანკი',
            receiver_bank_code: 'TBCBGE22',
            reason: "სს თელასის განამაწილებელ ქსელში ჩართვის ღირებულების 50%-ის დაფარვა. განცხადება №#{@app.effective_number}; TAXID: #{@app.rs_tin}.",
            amount: amount
          }
          render template: 'network/new_customer/paybill'
        }
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

  def upload_file
    with_application do
      @title = I18n.t('models.network_new_customer_application.actions.upload')
      if request.post? and params[:sys_file]
        @file = Sys::File.new(params.require(:sys_file).permit(:file))
        if @file.save
          @application.files << @file
          redirect_to new_customer_files_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.upload_complete')
        end
      else
        @file = Sys::File.new
      end
    end
  end

  def delete_file
    file = Sys::File.find(params[:id])
    application = file.mountable
    file.destroy
    redirect_to new_customer_files_url(id: application.id), notice: I18n.t('models.network_new_customer_application.actions.delete_complete')
  end

  def confirm_step
    with_application do
      @application.send("#{params[:step]}=", true)
      @application.save
      url = params[:tab] == 'general' ? new_customer_url(id: @application.id) : new_customer_files_url(id: @application.id)
      redirect_to url, notice: 'დადასტურება მიღებულია'
    end
  end

  def send_to_telasi
    with_application do
      @application.status = Network::NewCustomerApplication::STATUS_SENT
      if @application.save
        msg = 'თქვენი განცხადება გაგზავნილია თელასში'
        message = Sys::SmsMessage.new(message: msg.to_lat, messageable: @application, mobile: @application.mobile)
        message.send_sms! if message.save
        redirect_to new_customer_url(id: @application.id), notice: msg
      else
        redirect_to new_customer_url(id: @application.id), alert: 'თქვენი განცხადება ვერ გაიგზავნა!'
      end
    end
  end

  def nav
    @nav = { I18n.t('models.network_new_customer_application.actions.index_page.title') => new_customers_url }
    if @application
      if @application.new_record?
        @nav[I18n.t('models.network_new_customer_application.actions.new')] = create_new_customer_url
      else
        @nav["#{I18n.t('models.network_new_customer_application.application')} ##{@application.effective_number}"] = new_customer_url(id: @application.id)
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
      redirect_to new_customers_url, alert: 'application not found'
    end
  end

  def application_params; params.require(:network_new_customer_application).permit(:rs_tin, :mobile, :email, :address, :bank_code, :bank_account, :work_address, :address_code, :bank_code, :bank_account, :power, :voltage) end
end
