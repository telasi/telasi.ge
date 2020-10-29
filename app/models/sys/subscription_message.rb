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

  def self.send_confirmation_message
    batch_size = 500
    count = 0
    subscribers = Sys::Subscription.where(email: 'temo.chutlashvili*'.mongonize)
    # subscribers = Sys::Subscription.all
    emails = []
    subscribers.each_with_index do |subscriber, index|
      count = count + 1
      emails << { email: subscriber.email, id: index }
      if count == batch_size || index == subscribers.size - 1
        recipient_variables={}
        emails.each{ |email| recipient_variables[email[:email]]={id:email[:id]} }

        send_confirm_mail(emails, recipient_variabless, subscriber.generate_hash)

        emails = []
        count = 0
      end
    end
  end

  def send_confirm_mail(emails, recipient_variables, hash)
    emails.each do |email|
      RestClient::Request.execute(
        url: "https://api:#{Telasi::MAILGUN_KEY}@api.mailgun.net/v2/telasi.ge/messages", 
        method: :post, 
        payload: { from: "Telasi <subscriptions@telasi.ge>",
                   to:   email,
                   subject: 'Subscription comfirmation', 
                   html: %Q{<html>
                        <body>
                            <table cellspacing="0" cellpadding="0" style="height:100%;width:100%; position: absolute; top: 0; bottom: 0; left: 0; right: 0;">
                                <tr style="height: 45%; background-color: white;">
                                    <td colspan="3">
                                        <p style="color: teal; text-align: center;">Header</p>
                                    </td>
                                </tr>
                                <tr style="height: 10%; background-color:white;">
                                    <td width="33%">
                                    </td>
                                    <td width="33%">
                                        <a href="http://telasi.ge/subscription/subscribe_confirm?email=#{email}&hash=#{hash}"
                                                           style="-webkit-appearance: button;
                                                           -moz-appearance: button;
                                                           appearance: button;
                                                           text-decoration: none;
                                                           text-align: center;
                                                           vertical-align: middle;
                                                           width: 100%; 
                                                           padding: 12px 20px;
                                                           font-size:large; font-weight: bold;
                                                           border: 4px solid #226fbe;
                                                           color: #fff;
                                                           background: #226fbe;
                                                           -webkit-transition: none;
                                                           -moz-transition: none;
                                                           transition: none;
                                                           border-radius: 15px;">
                                            Subscribe
                                    </a>
                                    </td>
                                    <td width="33%">
                                    </td>
                                </tr>
                                <tr style="height: 45%; background-color: white;">
                                    <td colspan="3">
                                        <p style="color: teal; text-align: center;">Footer</p>
                                    </td>
                                </tr>
                            </table>
                        </body>
                    </html>},
                   :'recipient-variables' => recipient_variables.to_json
                    },
        verify_ssl: false
      )
    end
  end
end
