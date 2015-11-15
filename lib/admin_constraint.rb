#
# This constraint is used in routes.rb to secure Sidekiq.
class AdminConstraint
  def matches?(request)
    return false unless request.session[:user_id]
    user = Sys::User.find request.session[:user_id]
    user && user.admin?
  end
end
