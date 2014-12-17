# -*- encoding : utf-8 -*-
class Admin::DebtNotificationsController < ApplicationController
  def index
    @title='ვალის შეტყობინებები'
    @notifications=Customer::DebtNotification.desc(:_id).paginate(page:params[:page],per_page:10)
  end


  def send_sms
    # Customer::Registration.send_sms_for_today
    Customer::DebtNotification.send_notifications
    redirect_to admin_debt_notifications_url, notice: 'შეტყობინებები დაგზავნილია'
  end

  def nav
    @nav = {
      'რეგისტრაციები' => admin_customers_url,
      'ვალის შეტყობინებები' => admin_debt_notifications_url
    }
  end

end
