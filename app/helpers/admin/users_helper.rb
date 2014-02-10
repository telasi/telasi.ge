# -*- encoding : utf-8 -*-
module Admin::UsersHelper
  def user_form(user, opts = {})
    forma_for user, title: opts[:title], icon: '/icons/user.png', collapsible: true do |f|
      f.email_field 'email', required: true, readonly: !user.new_record?, autofocus: true
      f.text_field 'password', password: true
      f.text_field 'first_name', required: true
      f.text_field 'last_name', required: true
      f.text_field 'mobile', required: true
      f.boolean_field 'email_confirmed', readonly: (user == current_user)
      f.boolean_field 'admin', readonly: (user == current_user)
      f.submit 'შენახვა'
      f.cancel_button user.new_record? ? admin_users_url : admin_user_url(id: user.id)
    end
  end
end
