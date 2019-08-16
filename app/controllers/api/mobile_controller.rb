# -*- encoding : utf-8 -*-
class Api::NetworkController < Api::ApiController
  def login
    user = Sys::User.authenticate(params[:email].downcase, params[:password]) if params[:email]
    if user and user.email_confirmed and user.active 
        session[:user_id] = user.id
        url = session.delete(:return_url) || root_url
        render json: { success: true }
      elsif user and not user.email_confirmed then render json: { success: false, message: I18n.t('model.sys_user.errors.email_not_confirmed') }
      else render json: { success: false, message:  I18n.t('models.sys_user.errors.illegal_login') } end
  end
end
