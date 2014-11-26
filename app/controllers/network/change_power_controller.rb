# -*- encoding : utf-8 -*-
require 'rest_client'

class Network::ChangePowerController < ApplicationController
  def index
    @title = 'სიმძლავრის შეცვლა'
    @title = I18n.t('models.network_new_customer_application.actions.index_page.title')
    @search = params[:search] == 'clear' ? nil : params[:search]
    rel = Network::ChangePowerApplication
    if @search
      rel = rel.where(number: @search[:number].mongonize) if @search[:number].present?
      rel = rel.where(rs_name: @search[:rs_name].mongonize) if @search[:rs_name].present?
      rel = rel.where(rs_tin: @search[:rs_tin].mongonize) if @search[:rs_tin].present?
      rel = rel.where(status: @search[:status].to_i) if @search[:status].present?
      rel = rel.where(stage: Network::Stage.find(@search[:stage])) if @search[:stage].present?
      rel = rel.where(:send_date.gte => @search[:send_d1]) if @search[:send_d1].present?
      rel = rel.where(:send_date.lte => @search[:send_d2]) if @search[:send_d2].present?
      rel = rel.where(:start_date.gte => @search[:start_d1]) if @search[:start_d1].present?
      rel = rel.where(:start_date.lte => @search[:start_d2]) if @search[:start_d2].present?
      rel = rel.where(:end_date.gte => @search[:end_d1]) if @search[:end_d1].present?
      rel = rel.where(:end_date.lte => @search[:end_d2]) if @search[:end_d2].present?
      rel = rel.where(voltage: @search[:voltage]) if @search[:voltage].present?
      rel = rel.where(:power.gte => @search[:power1]) if @search[:power1].present? and @search[:power1].to_f >= 0
      rel = rel.where(:power.lte => @search[:power2]) if @search[:power2].present? and @search[:power2].to_f >= 0
      rel = rel.where(proeqti: @search[:proeqti].mongonize) if @search[:proeqti].present?
      rel = rel.where(oqmi: @search[:oqmi].mongonize) if @search[:oqmi].present?
      rel = rel.where(factura_seria: @search[:factura_seria]) if @search[:factura_seria].present?
      rel = rel.where(factura_number: @search[:factura_number].to_i) if @search[:factura_number].present?
      if @search[:accnumb].present?
        cust = Billing::Customer.where(accnumb: @search[:accnumb].strip.to_lat).first
        rel = rel.where(customer_id: cust.custkey) if cust.present?
      end
    end
    respond_to do |format|
      format.html { @applications = rel.desc(:_id).paginate(page: params[:page_change], per_page: 10) }
      format.xlsx { @applications = rel.desc(:_id).paginate(per_page: 3000) }
    end
  end

  def new
    @title = I18n.t('models.network_new_customer_application.actions.new')
    if request.post?
      @application = Network::ChangePowerApplication.new(change_power_params)
      @application.user = current_user
      @application.status = Network::NewCustomerApplication::STATUS_SENT
      if @application.save
        redirect_to network_change_power_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.created')
      end
    else
      @application = Network::ChangePowerApplication.new
    end
  end

  def show
    @application = Network::ChangePowerApplication.find(params[:id])
    @title = I18n.t('models.network_new_customer_application.actions.edit.title')
  end

  def sign
    @application = Network::ChangePowerApplication.find(params[:id])
    if params[:sdweb_result].present?
      if params[:sdweb_result] == 'success'
        @application.signed = true
        @application.save
      end
      redirect_to network_change_power_url  , notice: "ხელმოწერის შედეგი: #{params[:sdweb_result]}"
    else
      begin
        text = render_to_string 'show', formats: ['pdf']
        file = Tempfile.new(@application.id.to_s, encoding: 'ascii-8bit')
        file.write text
        file.close
        RestClient.post(Network::SDWEB_UPLOAD_URL, {
          docdata: File.new(file.path),
          cmd: Network::SDWEB_CMD_CHNGPOWAPP,
          resulturl: network_change_power_sign_url(id: @application.id),
          docid: @application.id.to_s,
          dmsid: Network::SDWEB_DMSID
        }, {
          'Content-Type' => 'multipart/form-data'
        }) do |response, request, result, &block|
          redirect_to response.headers[:location]
       end
      ensure
        file.unlink if file
      end
    end
  end

  def edit
    @title = I18n.t('models.network_new_customer_application.actions.edit.title')
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(change_power_params)
        redirect_to network_change_power_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.edit.changed')
      end
    end
  end

  def delete
    application = Network::ChangePowerApplication.find(params[:id])
    application.destroy
    redirect_to network_change_power_applications_url, notice: I18n.t('models.network_new_customer_application.actions.edit.changed')
  end

  def change_status
    @title = I18n.t('models.network_new_customer_application.actions.status.title')
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
      @message.messageable = @application
      @message.mobile = @application.mobile
      if @message.save
        @message.send_sms!(lat: true)
        @application.status = params[:status].to_i
        if @application.save
          redirect_to network_change_power_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.status.changed')
        else
          @error = @application.errors.full_messages
        end
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def upload_file
    @title = I18n.t('models.network_new_customer_application.actions.file.title')
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post? and params[:sys_file]
      @file = Sys::File.new(params.require(:sys_file).permit(:file))
      if @file.save
        @application.files << @file
        redirect_to network_change_power_url(id: @application.id, tab: 'files'), notice: I18n.t('models.network_new_customer_application.actions.file.loaded')
      end
    else
      @file = Sys::File.new
    end
  end

  def delete_file
    application = Network::ChangePowerApplication.find(params[:id])
    file = application.files.where(_id: params[:file_id]).first
    file.destroy
    redirect_to network_change_power_url(id: application.id, tab: 'files'), notice: I18n.t('models.network_new_customer_application.actions.file.deleted')
  end

  def send_sms
    @title = I18n.t('models.network_new_customer_application.actions.message.title')
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      @message = Sys::SmsMessage.new(params.require(:sys_sms_message).permit(:message))
      @message.messageable = @application
      @message.mobile = @application.mobile
      if @message.save
        @message.send_sms!(lat: true)
        redirect_to network_change_power_url(id: @application.id, tab: 'sms'), notice: I18n.t('models.network_new_customer_application.actions.message.sent')
      end
    else
      @message = Sys::SmsMessage.new
    end
  end

  def new_control_item
    @title = I18n.t('models.network_new_customer_application.actions.control.title')
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      @item = Network::RequestItem.new(params.require(:network_request_item).permit(:type, :date, :description, :stage_id))
      @item.source = @application
      if @item.save
        @application.update_last_request
        redirect_to network_change_power_url(id: @application.id, tab: 'watch'), notice: I18n.t('models.network_new_customer_application.actions.control.added')
      end
    else
      @item = Network::RequestItem.new(source: @application, date: Date.today)
    end
  end

  def edit_control_item
    @title = I18n.t('models.network_new_customer_application.actions.control.change')
    @item = Network::RequestItem.find(params[:id])
    if request.post?
      if @item.update_attributes(params.require(:network_request_item).permit(:type, :date, :description, :stage_id))
        @item.source.update_last_request
        redirect_to network_change_power_url(id: @item.source.id, tab: 'watch'), notice: I18n.t('models.network_new_customer_application.actions.control.changed')
      end
    end
  end

  def delete_control_item
    item = Network::RequestItem.find(params[:id])
    app = item.source
    item.destroy
    app.update_last_request
    redirect_to network_change_power_url(id: app.id, tab: 'watch'), notice: I18n.t('models.network_new_customer_application.actions.control.deleted')
  end

  def edit_amount
    @title = I18n.t('models.network_new_customer_application.actions.amount.title')
    @application = Network::ChangePowerApplication.find(params[:id])
    if request.post?
      if @application.update_attributes(params.require(:network_change_power_application).permit(:amount))
        redirect_to network_change_power_url(id: @application.id), notice: I18n.t('models.network_new_customer_application.actions.amount.changed')
      end
    end
  end

  def send_factura
    application = Network::ChangePowerApplication.find(params[:id])
    raise 'ფაქტურის გაგზავნა დაუშვებელია' unless application.can_send_factura?
    # factura = RS::Factura.new(date: Time.now, seller_id: RS::TELASI_PAYER_ID)
    factura = RS::Factura.new(date: application.end_date, seller_id: RS::TELASI_PAYER_ID)
    amount = application.amount
    raise 'თანხა უნდა იყოს > 0' unless amount > 0
    raise 'ფაქტურის გაგზავნა ვერ ხერხდება!' unless RS.save_factura(factura, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, buyer_tin: application.rs_tin))
    vat = application.pays_non_zero_vat? ? amount * (1 - 1.0 / 1.18) : 0
    factura_item = RS::FacturaItem.new(factura: factura, good: 'ქსელში ცვლილებების საფასური', unit: 'მომსახურეობა', amount: amount, vat: vat, quantity: 1)
    RS.save_factura_item(factura_item, RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID))
    if RS.send_factura(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))
      factura = RS.get_factura_by_id(RS::TELASI_SU.merge(user_id: RS::TELASI_USER_ID, id: factura.id))
      application.factura_seria = factura.seria
      application.factura_number = factura.number
    end
    application.factura_id = factura.id
    application.save
    redirect_to network_change_power_url(id: application.id, tab: 'factura'), notice: 'ფაქტურა გაგზავნილია :)'
  end

  def send_to_bs
    application = Network::ChangePowerApplication.find(params[:id])
    application.send_to_bs!
    redirect_to network_change_power_url(id: application.id, tab: 'operations'), notice: 'დარიცხვა გაგზავნილია ბილინგში'
  end

  def toggle_need_factura
    application = Network::ChangePowerApplication.find(params[:id])
    application.need_factura = (not application.need_factura)
    application.save
    redirect_to network_change_power_url(id: application.id), notice: 'სჭირდება ფაქტურა შეცვლილია'
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'ქსელში ცვლილება' => network_change_power_applications_url }
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

  def change_power_params; params.require(:network_change_power_application).permit(:base_type, :base_number, :need_factura, :work_by_telasi, :type, :number, :note, :rs_tin, :rs_foreigner, :rs_name, :vat_options, :mobile, :email, :region, :address, :work_address, :address_code, :bank_code, :bank_account, :voltage, :power, :old_voltage, :old_power, :customer_id, :proeqti, :oqmi) end
end
