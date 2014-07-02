# -*- encoding : utf-8 -*-
class Admin::SubscriptionsController < ApplicationController
  def index
    @title = I18n.t('applications.admin.subscriptions')
    @subscriptions = Sys::Subscription.desc(:_id).paginate(page: params[:page], per_page: 10)
    @news = Site::Node.where(type: 'news').order('created DESC').paginate(page: params[:news_page], per_page: 10)
    @not_sent = Sys::SubscriptionMessage.where(sent: false).asc(:_id)
  end

  def headline
    @node = Site::Node.find(params[:id])
    @title = @node.title
  end

  def nav
    @nav = { 'საწყისი' => admin_subscriptions_url }
    @nav[@title] = nil unless action_name == 'index'
  end

  def generate_messages
    Sys::SubscriptionMessage.generate_subscription_messages
    redirect_to admin_subscriptions_url, notice: 'გასაგზავნი წერილები დაგენერირებულია.'
  end

  def send_messages
    Sys::SubscriptionMessage.send_subscription_messages
    redirect_to admin_subscriptions_url, notice: 'წერილები დაგზავნილია.'
  end
end
