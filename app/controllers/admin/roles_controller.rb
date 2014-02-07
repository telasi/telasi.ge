# -*- encoding : utf-8 -*-
class Admin::RolesController < Admin::AdminController
  def index
    @title = 'როლები'
    @roles = Sys::Role.asc(:name)
  end

  def new
    @title = 'ახალი როლი'
    if request.post?
      @role = Sys::Role.new(params.require(:sys_role).permit(:name))
      if @role.save
        redirect_to admin_roles_url, notice: 'როლი დამატებულია'
      end
    else
      @role = Sys::Role.new
    end
  end

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url, 'როლები' => admin_roles_url }
    if @role
      @nav[@role.name] = admin_role_url(id: @role.id) unless @role.new_record?
      @nav[@title] = nil unless action_name == 'show'
    end
  end
end
