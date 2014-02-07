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

  def edit
    @title = 'როლის შეცვლა'
    @role = Sys::Role.find(params[:id])
    if request.post?
      if @role.update_attributes(params.require(:sys_role).permit(:name))
        redirect_to admin_roles_url, notice: 'შეცვლა'
      end
    end
  end

  def delete
    role = Sys::Role.find(params[:id])
    role.destroy
    redirect_to admin_roles_url, notice: 'როლი წაშლილია.'
  end

  def nav
    @nav = { 'მომხმარებლები' => admin_users_url, 'როლები' => admin_roles_url }
    if @role
      @nav[@title] = nil
    end
  end
end
