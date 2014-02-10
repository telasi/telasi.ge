# -*- encoding : utf-8 -*-
class Network::TariffsController < ApplicationController
  def index
    @title = I18n.t('models.network.tariffs.tariff')
    @tariffs = Network::NewCustomerTariff.asc(:_id)
  end

  def generate_tariffs
    Network::NewCustomerTariff.generate!
    redirect_to network_tariffs_url, notice: I18n.t('models.network.tariffs.generated')
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'ტარიფები' => nil }
  end
end
