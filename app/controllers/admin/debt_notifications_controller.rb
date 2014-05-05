# -*- encoding : utf-8 -*-
class Admin::DebtNotificationsController < ApplicationController
  def index
    @title='ვალის შეტყობინებები'
    @notifications=Customer::DebtNotification.desc(:_id).paginate(page:params[:page],per_page:10)
  end


  def nav
    @nav = {
      'რეგისტრაციები' => admin_customers_url,
      'ვალის შეტყობინებები' => admin_debt_notifications_url
    }
  end

end
