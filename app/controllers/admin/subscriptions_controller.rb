# -*- encoding : utf-8 -*-
class Admin::SubscriptionsController < ApplicationController
  def index
    @title = I18n.t('applications.admin.subscriptions')
    @not_sent = Sys::SubscriptionMessage.where(sent: false).asc(:_id).paginate(per_page: 20, page: params[:page])
  end

  def subscribers
    @title='სიახლეებზე ხელმოწერები'
    # @subscriptions = Sys::Subscription.desc(:_id).paginate(page: params[:page], per_page: 10)
    @subscriptions = Sys::Subscription
    search = params[:search] == 'clear' ? nil : params[:search]
    if search
      @subscriptions = @subscriptions.where(email: search[:email]) if search[:email].present?
    end
    @subscriptions = @subscriptions.desc(:_id).paginate(page: params[:page], per_page: 10)
  end

  def delete
    @subscriptions = Sys::Subscription.where(email: params[:email]).first
    @subscriptions.destroy if @subscriptions.present?
    redirect_to admin_subscribers_url, notice: '!!!'
  end

  def headlines
    @title='ყველა სიახლე'
    @headlines = Site::Node.where(type: 'news').order('created DESC').paginate(page: params[:news_page], per_page: 10)
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
