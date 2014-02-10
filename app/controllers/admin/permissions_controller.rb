# -*- encoding : utf-8 -*-
class Admin::PermissionsController < ApplicationController
  def index
    @title = 'როლები'
    @permissions = Sys::Permission.asc(:controller, :action)
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

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url, 'უფლებები' => admin_permissions_url }
    if @permission
      @nav[@title] = nil
    end
  end
end
