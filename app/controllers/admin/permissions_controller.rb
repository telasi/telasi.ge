# -*- encoding : utf-8 -*-
class Admin::PermissionsController < Admin::AdminController
  def index
    @title = 'როლები'
    @permissions = Sys::Permission.all
  end

  def sync
    Sys::Permission.sync
    redirect_to admin_permissions_url, notice: 'სინქრონიზაცია დასრულებულია.'
  end

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url, 'უფლებები' => admin_permissions_url }
    if @permission
      @nav[@title] = nil
    end
  end
end
