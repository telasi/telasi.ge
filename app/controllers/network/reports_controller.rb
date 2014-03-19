# -*- encoding : utf-8 -*-
class Network::ReportsController < ApplicationController
  def index
    @title = 'რეპორტები'
  end

  def by_status
    @title = 'განცხადებები სტატუსების მიხედვით'
    @d1 = Date.strptime(params[:d1], '%d-%b-%Y') rescue (Date.today - 30)
    @d2 = Date.strptime(params[:d2], '%d-%b-%Y') rescue Date.today
    @newapps = Network::NewCustomerApplication.where(:send_date.gte => @d1, :send_date.lte => @d2)
    @chgapps = Network::ChangePowerApplication.where(:send_date.gte => @d1, :send_date.lte => @d2)
  end

  def completed_apps
    @title = 'ქსელზე მიერთების შესრულებები'
    @d1 = Date.strptime(params[:d1], '%d-%b-%Y') rescue (Date.today - 30)
    @d2 = Date.strptime(params[:d2], '%d-%b-%Y') rescue Date.today
    stats = [Network::NewCustomerApplication::STATUS_COMPLETE, Network::NewCustomerApplication::STATUS_IN_BS]
    @newapps = Network::NewCustomerApplication.where(:send_date.gte => @d1, :send_date.lte => @d2, :status.in => stats)
  end

  def completed_apps_change_power
    @title = 'ქსელში ცლილების შესრულება'
    @d1 = Date.strptime(params[:d1], '%d-%b-%Y') rescue (Date.today - 30)
    @d2 = Date.strptime(params[:d2], '%d-%b-%Y') rescue Date.today
    stats = [Network::ChangePowerApplication::STATUS_COMPLETE, Network::ChangePowerApplication::STATUS_IN_BS]
    @apps = Network::ChangePowerApplication.where(:send_date.gte => @d1, :send_date.lte => @d2, :status.in => stats)
  end

  def nav
    @nav = { 'ქსელი' => network_home_url, 'რეპორტები' => network_reports_url }
    @nav[@title] = nil unless ['index'].include?(action_name )
    @nav
  end
end
