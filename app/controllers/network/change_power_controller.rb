# -*- encoding : utf-8 -*-
class Network::ChangePowerController < Network::NetworkController
  def index
    @title = 'სიმძლავრის შეცვლა'
    @applications = Network::ChangePowerApplication.desc(:_id).paginate(page: params[:page_change], per_page: 10)
  end

  def new
    @title = 'ახალი განცხადება'
    if request.post?
      @application = Network::ChangePowerApplication.new(change_power_params)
      @application.user = current_user
      @application.status = Network::NewCustomerApplication::STATUS_SENT
      if @application.save
        redirect_to network_change_power_url(id: @application.id), notice: 'განცხადება შექმნილია.'
      end
    else
      @application = Network::ChangePowerApplication.new
    end
  end

  def show
    @application = Network::ChangePowerApplication.find(params[:id])
    @title = 'განცხადების შეცვლა'
  end

  def edit
    @title = 'განცხადების შეცვლა'
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(change_power_params)
        redirect_to network_change_power_url(id: @application.id), notice: 'განცხადება შეცვლილია.'
      end
    end
  end

  def delete
    application = Network::ChangePowerApplication.find(params[:id])
    application.destroy
    redirect_to network_change_power_applications_url, notice: 'განცხადება წაშლილია.'
  end

  def change_status
    @title = 'სტატუსის ცვლილება'
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
      @message.messageable = @application
      @message.mobile = @application.mobile
      if @message.save
        @message.send_sms!
        @application.status = params[:status].to_i
        if @application.save
          redirect_to network_change_power_url(id: @application.id), notice: 'სტატუსი შეცვლილია'
        else
          @error = @application.errors.full_messages
        end
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'სიმძლავრის შეცვლა' => network_change_power_applications_url }
    if @application
      if not @application.new_record?
        @nav[ "№#{@application.number}" ] = network_change_power_url(id: @application.id)
        @nav[@title] = nil if action_name != 'show'
      else
        @nav['ახალი განცხადება'] = nil
      end
    end
    @nav
  end

  private

  def change_power_params
    params.require(:network_change_power_application).permit(:number, :rs_tin, :vat_options, :mobile, :email, :address, :work_address, :address_code, :bank_code, :bank_account, :voltage, :power, :old_voltage, :old_power, :customer_id)
  end
end
