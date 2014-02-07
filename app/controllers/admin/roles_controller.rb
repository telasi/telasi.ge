# -*- encoding : utf-8 -*-
class Admin::RolesController < Admin::AdminController
  def index
    @title = 'როლები'
    @roles = Sys::Role.asc(:name)
  end

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url, 'როლები' => admin_roles_url }
    # TODO
  end
end
