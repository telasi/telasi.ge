# -*- encoding : utf-8 -*-
class SubscriptionController < ApplicationController
  def subscribe
    @title = I18n.t('models.sys_subscription.actions.subscribe')
    if request.get?
      if current_user
        @subscription = current_user.subscription || Sys::Subscription.new(email: current_user.email)
      else
        @subscription = Sys::Subscription.new
      end
    else
      subs_params = params[:sys_subscription]
      @subscription = Sys::Subscription.where(email: subs_params[:email]).first || Sys::Subscription.new(email: subs_params[:email])
      @subscription.company_news = subs_params[:company_news]
      @subscription.procurement_news = subs_params[:procurement_news]
      @subscription.outage_news = subs_params[:outage_news]
      @subscription.locale = I18n.locale
      if @subscription.save
        if current_user
          redirect_to profile_url, notice: I18n.t('models.sys_subscription.actions.subscribe_complete')
        else
          redirect_to subscribe_complete_url
        end
      end
    end
  end

  def subscribe_item
    @title = I18n.t("models.sys_subscription.actions.#{params[:item]}")
    if request.get?
      redirect_to subscribe_url if !params[:item] || !Sys::Subscription.method_defined?(params[:item])
      @subscription = Sys::Subscription.new(company_news: false, procurement_news: false, outage_news: false)
    else
      subs_params = params[:sys_subscription]
      @subscription = Sys::Subscription.where(email: subs_params[:email]).first || Sys::Subscription.new(email: subs_params[:email], company_news: false, procurement_news: false, outage_news: false)
      @subscription.company_news = true if subs_params.key?(:company_news)
      @subscription.procurement_news = true if subs_params.key?(:procurement_news)
      @subscription.outage_news = true if subs_params.key?(:outage_news)
      @subscription.locale = I18n.locale
      if @subscription.save
        redirect_to subscribe_complete_url
      end
    end
  end  

  def unsubscribe
    @title = I18n.t('models.sys_subscription.actions.unsubscribe')
    if params[:email].present?
      subscription = Sys::Subscription.where(email: params[:email]).first
      subscription.destroy if subscription
      redirect_to unsubscribe_complete_url
    end
  end

  def subscribe_complete; @title = I18n.t('models.sys_subscription.actions.subscribe_complete') end
  def unsubscribe_complete; @title = I18n.t('models.sys_subscription.actions.unsubscribe_complete') end
end
