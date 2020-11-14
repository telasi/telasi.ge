# -*- encoding : utf-8 -*-
class Sys::SubscriptionConfirmMessage
	include Mongoid::Document
  	include Mongoid::Timestamps

  	field :email, type: String
	field :subject, type: String
	field :body, type: String
	field :attempts, type: Integer, default: 0
	field :sent, type: Mongoid::Boolean, default: false
	field :locale, type: String
	field :date, type: Date
end