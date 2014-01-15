# -*- encoding : utf-8 -*-
module BanksHelper
  def banks; Hash[Bank::BANKS.map{|k,v| ["#{k} &mdash; #{ t("banks.#{k}") }".html_safe,k]}] end
end
