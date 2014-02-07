# -*- encoding : utf-8 -*-
module ApplicationHelper
  def routes
    (Rails.application.routes.routes.select {|r| r.defaults[:controller]}).map {|r| {controller: r.defaults[:controller], action: r.defaults[:action], path: r.path.spec.to_s}}
  end
end
