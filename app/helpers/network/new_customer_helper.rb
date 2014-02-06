# -*- encoding : utf-8 -*-
module Network::NewCustomerHelper
  def new_customer_table(applications, opts = {})
    table_for applications, title: 'ახალი აბონენტის განცხადებები', icon: '/icons/user--plus.png', collapsible: true do |t|
      t.title_action network_add_new_customer_url, label: 'ახალი განცხადება', icon: '/icons/plus.png'
      t.text_field 'effective_number', i18n: 'number', tag: 'code'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name
      end
      t.complex_field i18n: 'rs_name' do |c|
        c.text_field :rs_tin, tag: 'code'
        c.text_field :rs_name, url: ->(x) { network_new_customer_url(id: x.id) }
      end
      t.complex_field label: 'სიმძლავრე/ძაბვა' do |c|
        c.number_field :power, after: 'kWh'
        c.number_field :voltage, before: '/'
      end
      t.number_field :amount, after: 'GEL'
      t.number_field :days, max_digits: 0, after: 'დღე'
      t.paginate param_name: 'page_new', records: 'ჩანაწერი'
    end
  end

  def vat_collection
    h = {}
    [Sys::VatPayer::NOT_PAYER, Sys::VatPayer::PAYER, Sys::VatPayer::PAYER_ZERO].each do |x|
      h[Sys::VatPayer.vat_name(x)] = x
    end
    h
  end

  def new_customer_form(application, opts = {})
    forma_for application, title: opts[:title], collapsible: true, icon: opts[:icon] do |f|
      f.tab do |t|
        t.text_field  :number, autofocus: true, label: 'ნომერი'
        t.complex_field label: 'საიდ.კოდი/უცხოელია?/დასახელება', required: true do |c|
          c.text_field  :rs_tin
          c.boolean_field :rs_foreigner
          c.text_field :rs_name, width: 400
        end
        t.combo_field :vat_options, collection: vat_collection, empty: false, i18n: 'vat_name', required: true
        t.boolean_field :need_factura, required: true
        t.boolean_field :show_tin_on_print, required: true
        t.boolean_field :personal_use, required: true
        t.text_field  :mobile, required: true
        t.email_field :email
        t.text_field  :address, required: true, width: 500
        t.text_field  :work_address, width: 500
        t.text_field  :address_code #, required: true
        t.combo_field :bank_code, collection: banks, empty: '-- აარჩიეთ ბანკი --' #empty: true, required: true
        t.text_field  :bank_account, width: 300 #, required: true
        t.combo_field :voltage, collection: voltage_collection, empty: false, required: true
        t.number_field :power, after: 'kWh', width: 100, required: true
        t.boolean_field :need_resolution, required: true
        t.text_field :notes, width: 500
      end
      f.submit (opts[:submit] || opts[:title])
      f.bottom_action opts[:cancel_url], label: 'გაუქმება', icon: '/icons/cross.png'
    end
  end

  private

  def selected_new_customer_tab
    case params[:tab]
    when 'accounts' then 1
    when 'sms' then 2
    when 'operations' then 3
    when 'files' then 4
    when 'factura' then 5
    when 'watch' then 6
    when 'sys' then 7
    else 0 end
  end

  def app_editable?(app)
    [
      Network::NewCustomerApplication::STATUS_DEFAULT,
      Network::NewCustomerApplication::STATUS_SENT,
      #Network::NewCustomerApplication::STATUS_CANCELED,
      Network::NewCustomerApplication::STATUS_CONFIRMED,
    ].include?(app.status)
  end

  def app_change_customer?(app)
    [
      Network::NewCustomerApplication::STATUS_DEFAULT,
      Network::NewCustomerApplication::STATUS_SENT,
      #Network::NewCustomerApplication::STATUS_CANCELED,
      Network::NewCustomerApplication::STATUS_CONFIRMED,
      Network::NewCustomerApplication::STATUS_COMPLETE,
    ].include?(app.status)
  end

  def app_change_dates?(app)
    [
      Network::NewCustomerApplication::STATUS_DEFAULT,
      Network::NewCustomerApplication::STATUS_SENT,
      Network::NewCustomerApplication::STATUS_CANCELED,
      Network::NewCustomerApplication::STATUS_CONFIRMED,
      Network::NewCustomerApplication::STATUS_COMPLETE,
    ].include?(app.status)
  end

  public

  def new_customer_view(application, opts = {})
    show_actions = (not opts[:without_actions])
    view_for application, title: "#{opts[:title]} &mdash; №#{application.number}".html_safe, collapsible: true, icon: '/icons/user.png', selected_tab: selected_new_customer_tab do |f|
      f.title_action network_delete_new_customer_url(id: application.id), label: 'განცხადების წაშლა', icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვვილად გინდათ ამ განცხადების წაშლა?' if (show_actions and current_user.admin)
      # 1. general
      f.tab title: 'ძირითადი', icon: '/icons/user.png' do |t|
        t.action network_new_customer_print_url(id: application.id, format: 'pdf'), label: 'განაცხადი', icon: '/icons/printer.png' if show_actions
        t.action network_new_customer_paybill_url(id: application.id), label: 'საგ. დავალება', icon: '/icons/clipboard-task.png' if show_actions
        t.action network_edit_new_customer_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png' if (show_actions and app_editable?(application))
        application.transitions.each do |status|
          t.action network_change_new_customer_status_url(id: application.id, status: status), label: Network::NewCustomerApplication.status_name(status), icon: Network::NewCustomerApplication.status_icon(status) if show_actions
        end
        t.text_field 'number', required: true, tag: 'code' do |f|
          f.action network_aviso_url(id: application.aviso_id), label: 'ავიზოს ნახვა', icon: '/icons/money.png' if application.aviso_id.present?
        end
        t.complex_field i18n: 'status_name', required: true do |c|
          c.image_field :status_icon
          c.text_field :status_name
        end
        t.complex_field i18n: 'rs_name', required: true do |c|
          c.text_field :rs_tin, tag: 'code'
          c.text_field :rs_name, url: ->(x) { network_new_customer_url(id: x.id) }
        end
        t.text_field :vat_name, required: true
        t.boolean_field :need_factura, required: true
        t.boolean_field :show_tin_on_print, required: true
        t.boolean_field :personal_use, required: true
        t.email_field :email
        t.text_field :formatted_mobile, required: true
        t.text_field :address, required: true, hint: 'განმცხადებლის მისამართი'
        t.complex_field i18n: 'work_address', required: true do |c|
          c.text_field 'address_code', tag: 'code', empty: false
          c.text_field 'work_address', empty: false
        end
        t.complex_field label: 'საბანკო ანგარიში', required: true do |c|
          c.text_field :bank_code, tag: 'code'
          c.text_field :bank_account
        end
        t.complex_field label: 'ძაბვა / სიმძლავრე', required: true do |c|
          c.text_field :voltage, tag: 'code'
          c.text_field :unit, after: '/'
          c.number_field :power, after: 'კვტ'
        end
        t.boolean_field :need_resolution, required: true
        t.text_field :notes
        t.col2 do |c|
          c.text_field 'stage', label: 'მიმდინარე ეტაპი'
          c.complex_field label: 'ბილინგის აბონენტი' do |c|
            c.text_field 'customer.accnumb', tag: 'code', empty: false
            c.text_field 'customer.custname'
            c.text_field 'customer.commercial', empty: false, before: '&mdash;'.html_safe
          end
          c.number_field :amount, after: 'GEL'
          c.number_field :days, max_digits: 0, after: 'დღე'
          c.number_field :paid, after: 'GEL'
          c.number_field :remaining, after: 'GEL'
          c.number_field :penalty_first_stage, after: 'GEL'
          c.number_field :penalty_second_stage, after: 'GEL'
          c.number_field :penalty_third_stage, after: 'GEL'
          c.date_field :send_date
          c.date_field :start_date
          c.date_field :end_date do |real|
            real.action network_change_real_date_url(id: application.id), icon: '/icons/pencil.png' if (application.end_date.present? and show_actions and app_change_dates?(application))
          end
          c.date_field :plan_end_date do |plan|
            plan.action network_change_plan_date_url(id: application.id), icon: '/icons/pencil.png' if (application.plan_end_date.present? and show_actions and app_change_dates?(application))
          end
        end
      end
      # 2. customers
      f.tab title: 'აბონენტები', icon: '/icons/users.png' do |t|
        if application.can_send_to_item?
          t.action network_new_customer_send_to_bs_url(id: application.id), label: 'ბილინგში გაგზავნა', icon: '/icons/wand.png', method: 'post', confirm: 'ნამდვილად გინდათ ბილინგში გაგზავნა?' if show_actions
        end
        t.complex_field label: 'ბილინგის აბონენტი' do |c|
          c.text_field 'customer.accnumb', tag: 'code', empty: false
          c.text_field 'customer.custname' 
          c.text_field 'customer.commercial', empty: false, before: '&mdash;'.html_safe do |cust|
            cust.action network_link_bs_customer_url(id: application.id), icon: '/icons/user--pencil.png' if (show_actions and app_change_customer?(application))
            if application.customer_id.present?
              cust.action network_remove_bs_customer_url(id: application.id), icon: '/icons/user--minus.png', method: 'delete', confirm: 'ნამდვილად გინდათ აბონენტის წაშლა?' if (show_actions and app_change_customer?(application))
            end
          end
        end
        t.table_field :items, table: { title: 'აბონენტების განშლა', icon: '/icons/users.png' } do |items|
          items.table do |t|
            t.title_action network_new_customer_sync_customers_url(id: application.id), label: 'სინქრონიზაცია ბილინგთან', icon: '/icons/arrow-circle-double-135.png', method: 'post', confirm: 'ნამდვილად გინდათ სინქრონიზაცია?' if (show_actions and app_change_customer?(application))
            t.complex_field label: 'ბილინგის აბონენტი' do |c|
              c.text_field 'customer.accnumb', tag: 'code'
              c.text_field 'customer.custname', empty: false
            end
            t.number_field 'amount', after: 'GEL'
            t.number_field 'amount_compensation', after: 'GEL', label: 'კომპენსაცია'
          end
        end
      end
      # 3. sms messages
      f.tab title: "SMS &mdash; <strong>#{application.messages.count}</strong>".html_safe, icon: '/icons/mobile-phone.png' do |t|
        t.table_field :messages, table: { title: 'SMS შეტყობინებები', icon: '/icons/mobile-phone.png' } do |sms|
          sms.table do |t|
            t.title_action network_send_new_customer_sms_url(id: application.id), label: 'SMS გაგზავნა', icon: '/icons/balloon--plus.png' if show_actions
            t.date_field :created_at, formatter: '%d-%b-%Y %H:%M:%S'
            t.text_field :mobile, tag: 'code'
            t.text_field :message
          end
        end
      end
      # 4. billing operations
      f.tab title: "ოპერაციები &mdash; <strong>#{application.billing_items.count}</strong>".html_safe, icon: '/icons/edit-list.png' do |t|
        t.table_field :billing_items, table: { title: 'ბილინგის ოპერაციები', icon: '/icons/edit-list.png' } do |operations|
          operations.table do |t|
            t.text_field 'customer.accnumb', tag: 'code', label: 'აბონენტი'
            t.date_field 'itemdate', label: 'თარიღი'
            t.complex_field label: 'ოპერაცია' do |c|
              c.text_field 'operation.billopername', after: '&mdash;'.html_safe
              c.text_field 'operation.billoperkey', class: 'muted'
            end
            t.number_field 'kwt', after: 'kWh', label: 'დარიცხვა'
            t.number_field 'amount', after: 'GEL', label: 'თანხა'
            t.number_field 'balance', after: 'GEL', label: 'ბალანსი'
          end
        end
      end
      # 5. files
      f.tab title: "ფაილები &mdash; <strong>#{application.files.count}</strong>".html_safe, icon: '/icons/book-open-text-image.png' do |t|
        t.table_field :files, table: { title: 'ფაილები', icon: '/icons/book-open-text-image.png' } do |files|
          files.table do |t|
            t.title_action network_upload_new_customer_file_url(id: application.id), label: 'ახალი ფაილის ატვირთვა', icon: '/icons/upload-cloud.png' if show_actions
            t.item_action ->(x) { network_delete_new_customer_file_url(id: application.id, file_id: x.id) }, icon: '/icons/bin.png', confirm: 'ნამდვილად გინდათ ფაილის წაშლა?', method: 'delete'
            t.text_field 'file.filename', url: ->(x) { x.file.url }, label: 'ფაილი'
          end
        end
      end
      # 6. factura
      f.tab title: 'ფაქტურა', icon: '/icons/money.png' do |t|
        if application.can_send_factura?
          t.action network_new_customer_send_factura_url(id: application.id), icon: '/icons/money--arrow.png', label: 'ფაქტურის გაგზავნა', method: 'post', confirm: 'ნამდვილად გინდათ ფაქტურის გაგზავნა?' if show_actions
        end
        t.number_field 'effective_amount', after: 'GEL'
        t.boolean_field 'factura_sent?'
        t.text_field 'factura_id', tag: 'code'
        t.complex_field i18n: 'factura_number' do |c|
          c.text_field 'factura_seria', tag: 'code', after: '&mdash;'.html_safe
          c.text_field 'factura_number', empty: false
        end
      end
      # 7. stages
      f.tab title: "კონტროლი &mdash; <strong>#{application.requests.count}</strong>".html_safe, icon: '/icons/eye.png' do |t|
        t.table_field :requests, table: { title: 'კონტროლი', icon: '/icons/eye.png' } do |requests|
          requests.table do |t|
            t.title_action network_new_customer_new_control_item_url(id: application.id), label: 'ახალი საკონტროლო ჩანაწერი', icon: '/icons/eye--plus.png'
            t.item_action ->(x) { network_new_customer_edit_control_item_url(id: x.id) }, icon: '/icons/pencil.png'
            t.item_action ->(x) { network_new_customer_delete_control_item_url(id: x.id) }, icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვილად გინდათ წაშლა?'
            t.text_field :stage
            t.text_field :type_name, i18n: 'type', tag: 'code'
            t.date_field :date, label: 'თარიღი'
            t.text_field :description
          end
        end
      end
      # 8. sys
      f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |t|
        t.complex_field label: 'მომხმარებელი', hint: 'მომხმარებელი, რომელმაც შექმნა ეს განცხადება', required: true do |c|
          c.email_field 'user.email', after: '&mdash;'.html_safe
          c.text_field 'user.full_name'
          c.text_field 'user.formatted_mobile', tag: 'code'
        end
        t.timestamps
        t.number_field 'payment_id', required: true, max_digits: 0
        t.boolean_field 'online', required: true
      end
    end
  end

  def sms_message_form(message, opts = {})
    forma_for message, title: opts[:title], icon: opts[:icon], collapsible: true do |f|
      f.text_field 'message', required: true, autofocus: true, width: 800
      f.submit opts[:submit]
      f.bottom_action opts[:cancel_url], label: 'გაუქმება', icon: '/icons/cross.png'
    end
  end

  def network_request_types_collection
    coll = {}
    [Network::RequestItem::OUT, Network::RequestItem::IN].each do |st|
      coll[Network::RequestItem.type_name(st)] = st
    end
    coll
  end

  def control_item_form(item, opts = {})
    if item.source.class == Network::NewCustomerApplication
      cancel_url = network_new_customer_url(id: item.source.id, tab: 'watch')
    elsif item.source.class == Network::ChangePowerApplication
      cancel_url = network_change_power_url(id: item.source.id, tab: 'watch')
    else
      raise 'unknown class'
    end
    forma_for item, title: opts[:title], collapsible: true, icon: opts[:icon] do |f|
      f.combo_field 'stage_id', collection: Network::Stage.asc(:numb), empty: false, required: true, i18n: 'stage'
      f.combo_field 'type', collection: network_request_types_collection, empty: false, required: true
      f.date_field 'date', required: true
      f.text_field 'description', width: 500, required: true, autofocus: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end
end
