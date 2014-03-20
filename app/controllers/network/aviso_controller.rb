# -*- encoding : utf-8 -*-
class Network::AvisoController < ApplicationController
  def index
    @title = 'ავიზოების მართვა'
    @search = params[:search] == 'clear' ? nil : params[:search]
    rel = Billing::Aviso.where(avtpkey: Billing::Aviso::NEW_CUSTOMER_APP)
    if @search
      rel = rel.where(basepointkey: @search['paypoint'].to_i) if @search['paypoint'].present?
      rel = rel.where("avdate >= ?", Date.strptime(@search['d1'])) if @search['d1'].present?
      rel = rel.where("avdate <= ?", Date.strptime(@search['d2'])) if @search['d2'].present?
      rel = rel.where(status: @search[:complete] == 'yes') if @search[:complete].present?
    end
    @avisos = rel.order('avdetkey DESC').paginate(page: params[:page], per_page: 10)
  end

  def show
    @title = 'ავიზოს პარამეტრები'
    @aviso = Billing::Aviso.find(params[:id])
    @application = @aviso.guessed_application unless @aviso.status
  end

  def edit
    @title = 'ავიზოს შეცვლა'
    @aviso = Billing::Aviso.find(params[:id])
    if request.post?
      num = params[:payments_avizo_detail][:cns]
      @aviso.cns = num
      app = Network::NewCustomerApplication.where(number: num).first
      app = Network::NewCustomerApplication.where(payment_id: num).first if app.blank?
      if app.present?
        @aviso.save
        redirect_to network_aviso_url(id: @aviso.id), notice: 'ავიზო შეცვლილია'
      end
    end
  end

  def link
    aviso = Billing::Aviso.find(params[:id])
    application = aviso.guessed_application
    aviso.status = true
    if aviso.save
      application.aviso_id = aviso.avdetkey
      application.customer_id = Billing::Customer.where(accnumb: aviso.accnumb).first.custkey rescue nil
      application.save
    end
    redirect_to network_aviso_url(id: aviso.avdetkey, tab: 'related'), notice: 'განცხადება დაკავშირებულია ავიზოსთან.'
  end

  def delink
    aviso = Billing::Aviso.find(params[:id])
    application = aviso.related_application
    aviso.status = false
    if aviso.save
      application.aviso_id = nil
      application.customer_id = nil
      application.save
    end
    redirect_to network_aviso_url(id: aviso.avdetkey), notice: 'განცხადება და ავიზო გამიჯნულია.'
  end

  def add_customer
    @aviso = Billing::Aviso.find(params[:id])
    @title = I18n.t('models.network.aviso.abonent_def')
    if params[:meter]
      @account = Billing::Account.where(mtnumb: params[:meter]).first
    elsif params[:custkey]
      customer = Billing::Customer.find(params[:custkey])
      @aviso.accnumb = customer.accnumb
      @aviso.status = true
      @aviso.save
      redirect_to network_aviso_url(id: @aviso.avdetkey), notice: 'აბონენტი დაკავშირებულია.'
    end
  end

  def sync
    Network::NewCustomerApplication.where(:aviso_id.ne => nil, customer_id: nil).each do |app|
      aviso = Billing::Aviso.find(app.aviso_id) rescue nil
      if aviso and aviso.accnumb.present?
        customer = Billing::Customer.where(accnumb: aviso.accnumb).first
        if customer
          app.customer_id = customer.custkey
          app.save
        end
      end
    end
    redirect_to network_avisos_url, notice: 'ავიზოების სინქრონიზირებულია.'
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'ავიზოები' => network_avisos_url }
    @nav['ავიზოს თვისებები'] = network_aviso_url(id: @aviso.avdetkey) if @aviso
    @nav[@title] = nil if ['add_customer', 'edit'].include?(action_name )
    @nav
  end
end
