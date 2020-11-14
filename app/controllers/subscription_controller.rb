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
         send_notification(@subscription)
        if current_user
          redirect_to profile_url, notice: I18n.t('models.sys_subscription.actions.subscribe_complete')
        else
          redirect_to subscribe_complete_url
        end
      end
    end
  end

  def subscribe_confirm
    @title = I18n.t('models.sys_subscription.actions.subscribe')
    hash = params[:hash]
    @subscription = Sys::Subscription.where(email: params[:email]).first
    if hash != @subscription.generate_hash
      redirect_to unsubscribe_complete_url
    else
      @subscription.assign_attributes(confirmed: true)  
      if @subscription.save
        redirect_to subscribe_complete_url
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
        send_notification(@subscription)
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

  def unsubscribe_confirm
    @title = I18n.t('models.sys_subscription.actions.unsubscribe')
    @subscription = Sys::Subscription.where(email: params[:email]).first
    @subscription.assign_attributes(company_news: false, outage_news: false)
    @subscription.save
    redirect_to unsubscribe_complete_url
  end

  def subscribe_complete; @title = I18n.t('models.sys_subscription.actions.subscribe_complete') end
  def unsubscribe_complete; @title = I18n.t('models.sys_subscription.actions.unsubscribe_complete') end

  def send_notification(subscription)
    strings = []

    strings << { en: "company news",
                 ge: "კომპანიის სიახლეები",
                 ru: "новости компании"
               } if subscription.company_news
    strings << { en: "procurement news",
                 ge: "სიახლეები თენდერებზე",
                 ru: "новости о закупках"
               } if subscription.procurement_news
    strings << { en: "outage news",
                 ge: "ენერგომომარაგების შეზღუდვის შეტყობინებები",
                 ru: "сообщения об ограничении электроэнергии"
               } if subscription.outage_news

    strings.drop(1).each { |a|
      if a.equal? strings.last
        a[:en] = " and " + a[:en]
        a[:ru] = " и "   + a[:ru]
        a[:ge] = " და "  + a[:ge]
      else
        a[:en] = ", " + a[:en]
        a[:ru] = ", " + a[:ru]
        a[:ge] = ", " + a[:ge]
      end
    }

    s = { en: '', ru: '', ge: ''}

    strings.each{ |a|
      s[:en] << a[:en]
      s[:ru] << a[:ru]
      s[:ge] << a[:ge]
    }

     RestClient.post "https://api:#{Telasi::MAILGUN_KEY}"\
        "@api.mailgun.net/v2/telasi.ge/messages",
        from: "Telasi <hello@telasi.ge>",
        to: subscription.email,
        subject: "www.telasi.ge Subscription",
        html: %Q{
          <html>
          <body>
            <font face="Tahoma">
            თქვენ გამოიწერეთ #{s[:ge]}
            <br><br>
            Вы подписались на #{s[:ru]}
            <br><br>
            You have subscribed to #{s[:en]}
            <br>
            <hr>
             </font>
             <font face="Tahoma" size="2">
            <span>
              <a href="http://www.telasi.ge" font-type>Telasi</a>&nbsp;2014 
              </span>
             </font>
          </body>
          </html>
        } unless strings.empty?
  end
end
