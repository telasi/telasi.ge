# -*- encoding : utf-8 -*-
class Sys::Permission
  include Mongoid::Document
  include Mongoid::Timestamps

  field :controller, type: String
  field :action, type: String
  field :path, type: String
  field :public_page, type: Mongoid::Boolean
  has_many :roles, class_name: 'Sys::Role'

  index({controller: 1, action: 1}, { unique: true })

  def self.routes; (Rails.application.routes.routes.select {|r| r.defaults[:controller]}).map {|r| {controller: r.defaults[:controller], action: r.defaults[:action], path: r.path.spec.to_s}} end
  def self.sync
    Sys::Permission.routes.each do |route|
      params = {controller: route[:controller], action: route[:action]}
      permission = Sys::Permission.where(params).first || Sys::Permission.new(params.merge(public_page: false))
      permission.path = route[:path]
      permission.save
    end
  end
end
