# -*- encoding : utf-8 -*-
class Admin::AdminController < ApplicationController
  before_action :validate_login
  before_action :validate_admin

  private

  def validate_admin
    if controller_name == 'subscriptions' and not current_user.news_admin?
      redirect_to login_url, alert: I18n.t('models.sys_user.errors.admin_required')
    elsif not current_user.admin?
      redirect_to login_url, alert: I18n.t('models.sys_user.errors.admin_required')
    end
  end
end
