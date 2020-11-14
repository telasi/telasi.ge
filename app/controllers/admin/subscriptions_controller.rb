# -*- encoding : utf-8 -*-
class Admin::SubscriptionsController < ApplicationController
  def index
    @title = I18n.t('applications.admin.subscriptions')
    @not_sent = Sys::SubscriptionMessage.where(sent: false).paginate(per_page: 20, page: params[:page])
  end

  def subscribers
    @title='სიახლეებზე ხელმოწერები'
    # @subscriptions = Sys::Subscription.desc(:_id).paginate(page: params[:page], per_page: 10)
    @subscriptions = Sys::Subscription
    @search = params[:search] == 'clear' ? nil : params[:search]
    if @search
      @subscriptions = @subscriptions.where(email: @search[:email]) if @search[:email].present?
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

  def generate_confirmations_source
    @title = 'Выберите список'
  end

  def generate_confirmations
    if params[:source][:type] == 'db'
      list = Sys::Subscription.or({ company_news: true }, { outage_news: true })
      list.each do |item|
        generate_confirm_message(item)
      end
    else
      list = params[:source][:list].split(/\r\n/)
      list.each do |item|
        @sub = Sys::Subscription.where(email: item).first
        next unless @sub
        if @sub.locale == 'ru'
          body = render_to_string 'subscription/sub_confirm_ru', layout: false
          subject = 'Подтвердите, пожалуйста, подписку на рассылку!'
        else
          body = render_to_string 'subscription/sub_confirm_ka', layout: false
          subject = 'გთხოვთ, დაადასტუროთ გამოწერა გზავნილებზე!'
        end
        Sys::SubscriptionConfirmMessage.new(email: item, subject: subject,
                                            body: body, locale: @sub.locale, date: Time.now).save
      end
    end
    redirect_to admin_subscriptions_url, notice: 'Сообщения подтвердения сгенерированы'
  end

  def confirmations
    @confirmations = Sys::SubscriptionConfirmMessage
    @search = params[:search] == 'clear' ? nil : params[:search]
    if @search
      @confirmations = @confirmations.where(email: @search[:email]) if @search[:email].present?
      @confirmations = @confirmations.where(sent: @search[:sent]) if @search[:sent].present?
    end
    @confirmations = @confirmations.desc(:_id).paginate(per_page: 20, page: params[:page])
  end

  def show_message
    @message = Sys::SubscriptionConfirmMessage.find(params[:id])
    render inline: "<%=raw @message.body %>"
  end

  private 

  def generate_confirm_message(item)
    @sub = item
    if item.locale == 'ru'
      body = render_to_string 'subscription/sub_confirm_ru', layout: false
      subject = 'Подтвердите, пожалуйста, подписку на рассылку!'
    else
      body = render_to_string 'subscription/sub_confirm_ka', layout: false
      subject = 'გთხოვთ, დაადასტუროთ გამოწერა გზავნილებზე!'
    end
    Sys::SubscriptionConfirmMessage.new(email: item.email, subject: subject,
                                        body: body, locale: item.locale, date: Time.now).save
  end
end
