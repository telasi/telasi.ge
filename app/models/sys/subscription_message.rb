# -*- encoding : utf-8 -*-
class Sys::SubscriptionMessage
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, type: String
  field :nid, type: Integer

  field :message_type, type: String
  field :subject, type: String
  field :body, type: String
  field :sent, type: Mongoid::Boolean, default: false
  field :locale, type: String
  field :date, type: Date

  # index(nid: 1, sent: 1)

  def subscirption; Sys::Subscription.where(email: self.email).first end
  def node; Site::Node.find(self.nid) end

  def self.generate_subscription_messages
    last_nid = Sys::SubscriptionMessage.max(:nid) rescue 0
    news = Site::Node.where('type = ? AND nid > ? AND created > ?', 'news', last_nid, (Time.now - 3.days).to_i)
    news.each do |headline|
      headline_type = headline.content_type.field_content_type_value
      Sys::Subscription.each do |subscription|
        if subscription.belong_to_type(headline_type) and headline.language == subscription.locale
          m = Sys::SubscriptionMessage.new(email: subscription.email, nid: headline.nid, message_type: headline_type,
            subject: headline.title, body: headline.content.body_value, locale: headline.language, date: headline.created_at)
          m.save
        end
      end
    end
  end

  def self.send_subscription_messages
    messages=Sys::SubscriptionMessage.where(sent: false)
    nodes=messages.map{|x| x.nid}.uniq
    nodes.each do |node|
      while true do
        node_messages=messages.where(nid: node).paginate(per_page:500, page:1)
        break if node_messages.empty?
        m=node_messages.first
        recipient_variables={}
        node_messages.each{ |msg| recipient_variables[msg.email]={id:msg.id.to_s} }
        # RestClient.post "https://api:#{Telasi::MAILGUN_KEY}"\
        #   "@api.mailgun.net/v2/telasi.ge/messages",
        #   from: "Telasi <subscriptions@telasi.ge>",
        #   to: node_messages.map{|x| x.email}.join(', '),
        #   subject: m.subject,
        #   html: %Q{<html><body>
        #     <h1 class="page-header">
        #     <a href="http://telasi.ge/#{m.locale}/node/#{m.nid}?ref=email">#{m.subject}</a>
        #     </h1>
        #     #{m.body}
        #     </body></html>},
        RestClient::Request.execute(
          url: "https://api:#{Telasi::MAILGUN_KEY}@api.mailgun.net/v2/telasi.ge/messages", 
          method: :post, 
          payload: { from: "Telasi <subscriptions@telasi.ge>",
                     to:   node_messages.map{|x| x.email}.join(', '),
                     subject: m.subject, 
                     html: %Q{<html><body>
                        <h1 class="page-header">
                        <a href="http://telasi.ge/#{m.locale}/node/#{m.nid}?ref=email">#{m.subject}</a>
                        </h1>
                        #{m.body}
                        </body></html>},
                     :'recipient-variables' => recipient_variables.to_json
                      },
          verify_ssl: false
        )
        node_messages.each { |msg| msg.sent=true ; msg.save }
      end
    end
  end
end