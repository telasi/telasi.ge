# -*- encoding : utf-8 -*-
class Network::NewCustomerController < Admin::AdminController
  layout 'one_column'

  def new_customer
    @title = 'ქსელზე მიერთების განცხადება'
    @application = Network::NewCustomerApplication.find(params[:id])
  end

  def add_new_customer
    @title = 'ქსელზე მიერთების ახალი განცხადება'
    if request.post?
      @application = Network::NewCustomerApplication.new(new_customer_params)
      @application.user = current_user
      if @application.save
        redirect_to network_new_customer_url(id: @application._id, tab: 'general'), notice: 'განცხადება დამატებულია'
      end
    else
      @application = Network::NewCustomerApplication.new
    end
  end

  def edit_new_customer
    @title = 'ქსელზე მიერთების განცხადების შეცვლა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @application.update_attributes(new_customer_params)
      redirect_to network_new_customer_url(id: @application._id, tab: 'general'), notice: 'განცხადება შეცვლილია'
    end
  end

  def delete_new_customer
    application = Network::NewCustomerApplication.find(params[:id])
    application.destroy
    redirect_to network_home_url, notice: 'განცხადება წაშლილია!'
  end

  def add_new_customer_account
    @title = 'ახალი აბონენტის დამატება'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @account = Network::NewCustomerItem.new(account_params)
      @account.application = @application
      if @account.save
        redirect_to network_new_customer_url(id: @application.id, tab: 'accounts'), notice: 'აბონენტი დამატებულია'
      end
    else
      @account = Network::NewCustomerItem.new
    end
  end

  def edit_new_customer_account
    @title = 'აბონენტის რედაქტირება'
    @application = Network::NewCustomerApplication.find(params[:app_id])
    @account = @application.items.where(id: params[:id]).first
    if request.post?
      if @account.update_attributes(account_params)
        @application.calculate!
        redirect_to network_new_customer_url(id: @application.id, tab: 'accounts'), notice: 'აბონენტი შეცვლილია'
      end
    end
  end

  def delete_new_customer_account
    application = Network::NewCustomerApplication.find(params[:app_id])
    account = application.items.where(id: params[:id]).first
    account.destroy
    application.calculate!
    redirect_to network_new_customer_url(id: application.id, tab: 'accounts')
  end

  def link_bs_customer
    @title = 'აბონენტის დაკავშირება'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @application.update_attributes(params.require(:network_new_customer_application).permit(:customer_id))
      redirect_to network_new_customer_url(id: @application.id, tab: 'accounts')
    end
  end

  def remove_bs_customer
    application = Network::NewCustomerApplication.find(params[:id])
    application.customer_id = nil
    application.save
    redirect_to network_new_customer_url(id: application.id, tab: 'accounts')
  end

  def calculate_distribution
    application = Network::NewCustomerApplication.find(params[:id])
    application.calculate_distribution!
    redirect_to network_new_customer_url(id: application.id, tab: 'accounts'), notice: 'განაწილება დათვლილია'
  end

  def send_to_bs
    application = Network::NewCustomerApplication.find(params[:id])
    application.send_to_bs!
    redirect_to network_new_customer_url(id: application.id, tab: 'general'), notice: 'აბონენტი გაგზავნილია ბილინგში'
  end

  def change_status
    @title = 'სტატუსის ცვლილება'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
      @message.messageable = @application
      @message.mobile = @application.mobile
      if @message.save
        @message.send_sms!
        @application.status = params[:status].to_i
        @application.save
        redirect_to network_new_customer_url(id: @application.id), notice: 'სტატუსი შეცვლილია'
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def send_new_customer_sms
    @title = 'შეტყობინების გაგზავნა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
      @message.messageable = @application
      @message.mobile = @application.mobile
      if @message.save
        @message.send_sms!
        redirect_to network_new_customer_url(id: @application.id, tab: 'sms'), notice: 'შეტყობინება გაგზავნილია'
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def upload_file
    @title = 'ფაილის ატვირთვა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post? and params[:sys_file]
      @file = Sys::File.new(params.require(:sys_file).permit(:file))
      if @file.save
        @application.files << @file
        redirect_to network_new_customer_url(id: @application.id, tab: 'files'), notice: 'ფაილი დამატებულია'
      end
    else
      @file = Sys::File.new
    end
  end

  def delete_file
    application = Network::NewCustomerApplication.find(params[:id])
    file = application.files.where(_id: params[:file_id]).first
    file.destroy
    redirect_to network_new_customer_url(id: application.id, tab: 'files'), notice: 'ფაილი წაშლილია'
  end

  def change_plan_date
    @title = 'გეგმიური დასრულების თარიღის შეცვლა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(params.require(:network_new_customer_application).permit(:plan_end_date))
        redirect_to network_new_customer_url(id: @application.id), notice: 'გეგმიური დასრულების თარიღი შეცვლილია'
      end
    end
  end

  def change_real_date
    @title = 'დასრულების თარიღის შეცვლა'
    @application = Network::NewCustomerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(params.require(:network_new_customer_application).permit(:end_date))
        redirect_to network_new_customer_url(id: @application.id), notice: 'დასრულების თარიღი შეცვლილია'
      end
    end
  end

  protected

  def nav
    @nav = { 'ქსელი' => network_home_url }
    if @application
      if not @application.new_record?
        @nav[ "№#{@application.number}" ] = network_new_customer_url(id: @application.id)
        @nav[@title] = nil if action_name != 'new_customer'
      else
        @nav['ახალი განცხადება'] = nil
      end
    end
    @nav
  end

  private

  def new_customer_params; params.require(:network_new_customer_application).permit(:number, :rs_tin, :mobile, :email, :address, :address_code, :bank_code, :bank_account, :need_resolution, :voltage, :power) end
  def account_params; params.require(:network_new_customer_item).permit(:address, :address_code, :rs_tin, :customer_id) end
end