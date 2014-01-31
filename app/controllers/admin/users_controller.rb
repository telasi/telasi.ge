# -*- encoding : utf-8 -*-
class Admin::UsersController < Admin::AdminController
  def index
    @title = I18n.t('applications.admin.users')
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Sys::User
    if @search
      rel = rel.where(email: @search[:email].mongonize) if @search[:email].present?
      rel = rel.where(first_name: @search[:first_name].mongonize) if @search[:first_name].present?
      rel = rel.where(last_name: @search[:last_name].mongonize) if @search[:last_name].present?
      rel = rel.where(email_confirmed: @search[:confirmed] == 'yes') if @search[:confirmed].present?
      rel = rel.where(admin: @search[:admin] == 'yes') if @search[:admin].present?
      rel = rel.where(network_admin: @search[:network_admin] == 'yes') if @search[:network_admin].present?
      rel = rel.where(news_admin: @search[:news_admin] == 'yes') if @search[:news_admin].present?
    end
    @users = rel.desc(:_id).paginate(page: params[:page], per_page: 20)
  end

  def show
    @title = I18n.t('models.sys_user.actions.admin_show')
    @user = Sys::User.find(params[:id])
  end

  def new
    @title = 'ახალი მომხმარებელი'
    if request.post?
      @user = Sys::User.new(user_params)
      if @user.save
        redirect_to admin_user_url(id: @user.id), notice: 'მომხმარებელი შექმნილია'
      end
    else
      @user = Sys::User.new
    end
  end

  def edit
    @title = I18n.t('models.sys_user.actions.edit')
    @user = Sys::User.find(params[:id])
    if request.post?
      if @user.update_attributes(user_params)
        redirect_to admin_user_url(id: @user.id), notice: I18n.t('models.sys_user.actions.edit_complete')
      end
    end
  end

  def delete
    user = Sys::User.find(params[:id])
    if user != current_user
      user.destroy
      redirect_to admin_users_url, notice: 'მომხმარებელი წაშლილია'
    else
      redirect_to admin_user_url(id: user.id), alert: 'მომხმარებელი ვერ წაიშალა'
    end
  end

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url }
    if @user
      @nav[@user.full_name] = admin_user_url(id: @user.id) unless @user.new_record?
      @nav[@title] = nil unless action_name == 'show'
    end
  end

  private

  def user_params; params.require(:sys_user).permit(:email, :password, :first_name, :last_name, :mobile, :admin, :email_confirmed, :network_admin, :news_admin) end
end
