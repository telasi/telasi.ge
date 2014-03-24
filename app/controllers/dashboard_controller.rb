# -*- encoding : utf-8 -*-
class DashboardController < ApplicationController
  def index; @title = I18n.t('dashboard.title') end
  def register_complete; @title = I18n.t('models.sys_user.actions.register_complete') end
  def restore; @title = I18n.t('models.sys_user.actions.restore') end

  def login
    @title = I18n.t('dashboard.login')
    user = Sys::User.authenticate(params[:email], params[:password])
    if request.post?
      if user and user.email_confirmed and user.active 
        session[:user_id] = user.id
        url = session.delete(:return_url) || root_url
        redirect_to url || root_url
      elsif not user.email_confirmed then @error = I18n.t('model.sys_user.errors.email_not_confirmed')
      else @error = I18n.t('models.sys_user.errors.illegal_login') end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to root_url
  end

  def register
    @title = I18n.t('models.sys_user.actions.register')
    if request.post?
      @user = Sys::User.new(params.require(:sys_user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :mobile))
      if @user.save
        UserMailer.email_confirmation(@user).deliver if @user.email_confirm_hash
        redirect_to register_complete_url
      end
    else
      @user = Sys::User.new
    end
  end

  def confirm
    @title = I18n.t('models.sys_user.actions.confirm_email')
    @user = Sys::User.find(params[:id]) rescue nil
    if @user and @user.confirm_email!(params[:c]) then @success = I18n.t('models.sys_user.actions.confirm_success')
    else @error = I18n.t('models.sys_user.actions.confirm_failure') end
  end

  def restore
    @title = I18n.t('models.sys_user.actions.restore')
    if request.post?
      user = Sys::User.where(email: params[:email]).first
      if user
        UserMailer.restore_password(user).deliver
        redirect_to restore_url(ok: 'ok')
      else
        @error = I18n.t('models.sys_user.errors.illegal_email')
      end
    end
  end

  def restore_password
    @title = I18n.t('models.sys_user.actions.restore')
    @user = Sys::User.find(params[:id]) rescue nil
    @user = nil if @user.password_restore_hash != params[:h]
    if request.post?
      if params[:password].blank?
        @error = I18n.t('models.sys_user.errors.empty_password')
      elsif params[:password] != params[:password_confirmation]
        @error = I18n.t('models.sys_user.errors.password_not_match')
      else
        @user.password = params[:password]
        @user.save
        redirect_to login_url, notice: I18n.t('models.sys_user.actions.restore_complete')
      end
    end
  end
end
