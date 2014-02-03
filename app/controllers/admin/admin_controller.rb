# -*- encoding : utf-8 -*-
class Admin::AdminController < ApplicationController
  before_action :validate_login
  before_action :validate_admin

  private

  def validate_admin
    valid = (if controller_name == 'subscriptions' and current_user.news_admin? then true
      elsif current_user.admin? then true
      else false end)
    redirect_to login_url, alert: I18n.t('models.sys_user.errors.admin_required') unless valid
  end
end
