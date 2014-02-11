# -*- encoding : utf-8 -*-
class Admin::PermissionsController < ApplicationController
  def index
    @title = 'როლები'
    @search = params[:search] == 'clear' ? {} : params[:search]
    rel = Sys::Permission
    if @search
      rel = rel.where(controller: @search[:controller].mongonize) if @search[:controller].present?
      rel = rel.where(action: @search[:action].mongonize) if @search[:action].present?
      rel = rel.where(admin_page: @search[:admin] == 'yes') if @search[:admin].present?
      rel = rel.where(public_page: @search[:public] == 'yes') if @search[:public].present?
    end
    @permissions = rel.asc(:controller, :action)
  end

  def sync
    Sys::Permission.sync
    redirect_to admin_permissions_url, notice: 'სინქრონიზაცია დასრულებულია.'
  end

  def show
    @title = 'უფლების თვისებები'
    @permission = Sys::Permission.find(params[:id])
  end

  def toggle_public
    permission = Sys::Permission.find(params[:id])
    permission.public_page = !permission.public_page
    permission.save
    redirect_to admin_permission_url(id: permission.id)
  end

  def toggle_admin
    permission = Sys::Permission.find(params[:id])
    permission.admin_page = !permission.admin_page
    permission.save
    redirect_to admin_permission_url(id: permission.id)
  end

  def add_role
    @title = 'როლის დამატება'
    @permission = Sys::Permission.find(params[:permission_id])
    if request.post?
      @role = Sys::Role.find(params[:role_id])
      unless @permission.roles.include?(@role)
        @permission.roles << @role
        @permission.save
      end
      redirect_to admin_permission_url(id: @permission.id, tab: 'roles'), notice: 'როლი დამატებულია'
    end
  end

  def remove_role
    permission = Sys::Permission.find(params[:permission_id])
    role = Sys::Role.find(params[:role_id])
    permission.roles.delete(role)
    permission.save
    redirect_to admin_permission_url(id: permission.id, tab: 'roles'), notice: 'როლი წაშლილია'
  end

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url, 'უფლებები' => admin_permissions_url }
    if @permission
      @nav[@title] = nil
    end
  end
end
