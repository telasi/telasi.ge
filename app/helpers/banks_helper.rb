# -*- encoding : utf-8 -*-
module BanksHelper
  def banks; banks=Bank.banks;Hash[banks.map{|k,v| ["#{k} &mdash; #{ t("banks.#{k}") }".html_safe,k]}] end
end
