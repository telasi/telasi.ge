# -*- encoding : utf-8 -*-
class Network::TariffsController < ApplicationController
  def index
    @title = I18n.t('models.network.tariffs.tariff')
    @tariffs = Network::NewCustomerTariff.asc(:ends, :voltage, :power_from)
    @mtariffs = Network::MicroTariff.asc(:_id)
    @tariffs_multi = Network::TariffMultiplier.asc(:_id)
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'ტარიფები' => nil }
  end
end
