# -*- encoding : utf-8 -*-
class Network::BaseController < Network::NetworkController
  def index
    @title = I18n.t('models.network.network')
    @new_customers = Network::NewCustomerApplication.desc(:_id).paginate(page: params[:page_new], per_page: 10)
    @change_powers = Network::ChangePowerApplication.desc(:_id).paginate(page: params[:page_change], per_page: 10)
  end
end
