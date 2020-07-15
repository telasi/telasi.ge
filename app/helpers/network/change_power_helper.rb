# -*- encoding : utf-8 -*-
module Network::ChangePowerHelper
  def change_power_table(applications, opts = {})
    table_for applications, title: 'ქსელში ცვლილების განცხადებები', icon: '/icons/user--pencil.png', collapsible: true do |t|
      t.title_action network_add_change_power_url, label: 'ახალი განცხადება', icon: '/icons/plus.png'
      t.title_action opts[:xlsx], label: 'ექსელში გადმოწერა', icon: '/icons/document-excel.png' if opts[:xlsx].present?
      t.text_field 'number', i18n: 'number', tag: 'code'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name, url: ->(x) { network_change_power_url(id: x.id) }
      end
      t.complex_field i18n: 'rs_name' do |c|
        c.text_field :rs_tin, tag: 'code'
        c.text_field :rs_name, url: ->(x) { network_change_power_url(id: x.id) }
      end
      t.complex_field label: 'სიმძლავრე/ძაბვა' do |c|
        c.number_field :power, after: 'kWh'
        c.number_field :voltage, before: '/'
      end
      t.number_field :amount, after: 'GEL'

      t.complex_field label: 'რეალური დასრულება', required: true do |c|
       c.date_field :real_end_date  #do |real|
        # real.action network_change_power_edit_real_date_url(id: id), label: 'შეცვლა', icon: '/icons/pencil.png'
      #end
       # c.image_field '/icons/pencil.png', label: 'შეცვლა', icon: '/icons/pencil.png', url: ->(x) { network_change_power_edit_real_date_url(id: x.id) }
      end 
      if params[:page_change].present?
        page = params[:page_change]
      else
        page = 0
      end
      t.item_action ->(x) { network_change_power_edit_real_date_url(id: x.id, page: page) }, icon: '/icons/pencil.png'

      t.paginate param_name: 'page_change', records: 'ჩანაწერი'
    end
  end

  def change_prepayment_table(applications, opts = {})
    table_for applications, title: 'განაცხადები ღია საავანსო განცხადებით', icon: '/icons/user--plus.png', collapsible: true do |t|
      t.title_action opts[:xlsx], label: 'ექსელში გადმოწერა', icon: '/icons/document-excel.png' if opts[:xlsx].present?
      t.text_field 'effective_number', i18n: 'number', tag: 'code'
      t.date_field 'start_date', i18n: 'start_date'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name, url: ->(x) { network_change_power_url(id: x.id) }
      end
      t.complex_field i18n: 'rs_name' do |c|
        c.text_field :rs_tin, tag: 'code'
        c.text_field :rs_name, url: ->(x) { network_change_power_url(id: x.id) }
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

  def change_accounting_table(applications, opts = {})
    table_for applications, title: 'ახალი აბონენტის განცხადებები', icon: '/icons/user--plus.png', collapsible: true do |t|
      t.title_action opts[:xlsx], label: 'ექსელში გადმოწერა', icon: '/icons/document-excel.png' if opts[:xlsx].present?
      t.text_field 'number', i18n: 'number', tag: 'code'
      t.text_field 'type_name', i18n: 'type', tag: 'code'
      t.text_field 'customer.accnumb', label: 'აბონენტის N', tag: 'code'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name, url: ->(x) { network_change_power_url(id: x.id) }
      end
      t.number_field :amount, after: 'GEL'
      t.date_field :send_date
      t.date_field :production_date
      t.date_field :real_end_date, label: 'რეალური დასრულება'
      t.date_field :end_date
      t.number_field :billing_prepayment_total, label: 'მობმული ავანსების თანხა'
      t.number_field :prepayment_percent, label: 'მობმული ავანსის %'
      
      t.paginate param_name: 'page_new', records: 'ჩანაწერი'
    end
  end

  def change_power_service_collection
    h = {}
    Network::ChangePowerApplication::SERVICES.each do |x|
      h[Network::ChangePowerApplication.service_name(x)] = x
    end
    h
  end

  def change_power_type_collection
    h = {}
    Network::ChangePowerApplication::TYPES.each do |x|
      h[Network::ChangePowerApplication.type_name(x)] = x
    end
    h
  end

  def change_power_form(application, opts = {})
    forma_for application, title: opts[:title], collapsible: true, icon: opts[:icon] do |f|
      f.tab do |t|
        t.combo_field :service, required: true, autofocus: true, collection: change_power_service_collection, empty: false
        t.combo_field :type, required: true, collection: change_power_type_collection, empty: false
        t.text_field  :tech_condition_cns, label: 'ტექპირობის ნომერი'
        t.combo_field :customer_type_id, required: true, collection: customer_type_collection, empty: false
        t.text_field  :number, required: true, label: 'ნომერი'
        # t.text_field  :rs_tin, required: true
        t.complex_field label: 'საიდ.კოდი/უცხოელია?/დასახელება', required: true do |c|
          c.text_field  :rs_tin
          c.boolean_field :rs_foreigner
          c.text_field :rs_name, width: 400
        end
        # t.boolean_field :rs_vat_payer, required: true
        t.combo_field :vat_options, collection: vat_collection, empty: false, i18n: 'vat_name', required: true
        t.boolean_field :need_factura, required: true
        t.boolean_field :work_by_telasi, required: true
        t.boolean_field :zero_charge, label: 'ნულოვანი დარიცხვა?'
        t.text_field  :mobile, required: true
        t.email_field :email
        t.combo_field :region, collection: regions_collection, empty: '--'
        t.text_field  :address, required: true, width: 500
        t.text_field  :work_address, width: 500
        t.text_field  :address_code #, required: true
        t.combo_field :bank_code, collection: banks, empty: '-- აარჩიეთ ანგარიში --'
        t.text_field  :bank_account, width: 300
        f.select_field :customer, select_customer_url, label: 'დროებითი აბონენტი', search_width: 900
        f.select_field :real_customer, select_customer_url, label: 'რეალური აბონენტი', search_width: 900
        t.combo_field :old_voltage, collection: voltage_collection_change_power, empty: false
        t.number_field :old_power, after: 'kWh', width: 100
        t.combo_field :voltage, collection: voltage_collection_change_power, empty: false, required: true
        t.number_field :power, after: 'kWh', width: 100, required: true
        t.number_field :abonent_amount, width: 50, required: true
        t.combo_field :duration, collection: duration_collection, empty: false, required: true, label: 'შესრულების ხანგრძლიობა' if application.apply_duration?
        t.combo_field :micro_power_source, collection: micro_power_source_collection, empty: false, label: 'მიკროსიმძლავრის პირველადი ენერგიის წყარო' 
        t.text_field :substation, width: 500
        t.text_field :note, width: 400
        t.text_field :oqmi
        t.text_field :proeqti
      end
      f.submit (opts[:submit] || opts[:title])
      f.bottom_action opts[:cancel_url], label: 'გაუქმება', icon: '/icons/cross.png'
    end
  end

  private

  def selected_change_power_tab
    case params[:tab]
    when 'operations' then 1
    when 'sms'        then 2
    when 'files'      then 3
    when 'watch'      then 4
    when 'factura'    then 5
    when 'sys'        then 6
    else 0 end
  end

  def change_power_app_editable?(app)
    [
      Network::ChangePowerApplication::STATUS_DEFAULT,
      Network::ChangePowerApplication::STATUS_SENT,
      #Network::ChangePowerApplication::STATUS_CANCELED,
      Network::ChangePowerApplication::STATUS_CONFIRMED,
      Network::ChangePowerApplication::STATUS_COMPLETE,
    ].include?(app.status)
  end

  public

  def change_power_view(application, opts = {})
    view_for application, title: 'განცხადების თვისებები', collapsible: true, icon: '/icons/user--pencil.png', selected_tab: selected_change_power_tab do |f|
      f.title_action network_delete_change_power_url(id: application.id), label: 'განცხადების წაშლა', icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვვილად გინდათ ამ განცხადების წაშლა?'
      # 1. general
      f.tab title: 'ძირითადი', icon: '/icons/user.png' do |t|
        t.action network_change_power_url(id: application.id, format: 'pdf'), label: 'განცხადების ბეჭდვა', icon: '/icons/printer.png'
        t.action network_change_power_print_cost_form_url(id: application.id, format: 'pdf'), label: 'აღრიცხვის ფორმა', icon: '/icons/report.png'
        t.action network_change_power_sign_url(id: application.id), label: 'ხელმოწერა', icon: '/icons/edit-signiture.png'
        #if Network::ACTIVATE_SDWEB and not application.signed
        #  t.action network_change_power_sign_url(id: application.id), label: 'ხელმოწერა', icon: '/icons/edit-signiture.png'
        #end
        # t.action network_new_customer_paybill_url(id: application.id, format: 'pdf'), label: 'საგ/დავ ბეჭდვა', icon: '/icons/printer.png'
        t.action network_change_power_change_dates_url(id: application.id), label: 'თარიღების შეცვლა', icon: '/icons/alarm-clock--pencil.png'
        t.action network_edit_change_power_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png' if change_power_app_editable?(application)
        application.transitions.each do |status|
          t.action network_change_change_power_status_url(id: application.id, status: status), label: Network::ChangePowerApplication.status_name(status), icon: Network::ChangePowerApplication.status_icon(status)
        end
        t.text_field 'service_name', required: true, i18n: 'service'
        t.text_field 'type_name', required: true, i18n: 'type'
        t.text_field 'number', required: true, tag: 'code'
        t.text_field 'tech_condition_cns', label: 'ტექპირობის ნომერი'
        t.complex_field i18n: 'status_name', required: true do |c|
          c.image_field :status_icon
          c.text_field :status_name
        end
        t.text_field 'customer_type_name', required: true, i18n: 'customer_type_id'
        t.complex_field i18n: 'rs_name', required: true do |c|
          c.text_field :rs_tin, tag: 'code'
          c.text_field :rs_name, url: ->(x) { network_change_power_url(id: x.id) }
        end
        t.text_field :vat_name, required: true
        t.boolean_field 'need_factura', required: true do |f|
          f.action network_change_power_toggle_need_factura_url(id: application.id), label: 'შეცვლა', icon: '/icons/arrow-repeat.png', method: 'post', confirm: ' ნამდვილად გინდათ ფაქტურის საჭიროების შეცვლა?'
        end
        t.boolean_field 'work_by_telasi', required: true
        t.boolean_field :zero_charge, label: 'ნულოვანი დარიცხვა?'
        t.email_field :email
        t.text_field :mobile, required: true
        t.text_field :region
        t.text_field :address, required: true, hint: 'განმცხადებლის მისამართი'
        t.complex_field i18n: 'work_address', required: true do |c|
          c.text_field 'address_code', tag: 'code', empty: false
          c.text_field 'work_address', empty: false
        end
        t.complex_field label: 'საბანკო ანგარიში', required: true do |c|
          c.text_field :bank_code, tag: 'code'
          c.text_field :bank_account, empty: false
        end
        t.text_field :abonent_amount, required: true
        t.complex_field label: 'არსებული ძაბვა / სიმძლავრე', required: true do |c|
          c.text_field :old_voltage, tag: 'code'
          c.text_field :old_unit, after: '/'
          c.number_field :old_power, after: 'კვტ'
        end
        t.complex_field label: 'ახალი ძაბვა / სიმძლავრე', required: true do |c|
          c.text_field :voltage, tag: 'code'
          c.text_field :unit, after: '/'
          c.number_field :power, after: 'კვტ'
        end

        t.text_field :duration_name, label: 'შესრულების ხანგრძლიობა', required: true if application.apply_duration?
        t.text_field :substation
        t.text_field :note
        t.text_field :oqmi
        t.text_field :proeqti
        t.col2 do |c|
          c.text_field 'stage', label: 'მიმდინარე ეტაპი'
          c.complex_field label: 'დროებითი აბონენტი', required: true do |c|
            c.text_field 'customer.accnumb', tag: 'code'
            c.text_field 'customer.custname'
          end
          c.complex_field label: 'რეალური აბონენტი', required: true do |c|
            c.text_field 'real_customer.accnumb', tag: 'code'
            c.text_field 'real_customer.custname'
          end
          c.number_field :amount, after: 'GEL' do |amnt|
            amnt.action(network_change_power_edit_amount_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png') if application.can_change_amount?
          end
          c.number_field :minus_amount, after: 'GEL' do |amnt|
            amnt.action(network_change_power_edit_minus_amount_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png')
          end  unless application.can_change_amount?

          if application.apply_duration?
            unitname = application.use_business_days ? 'სამუშაო დღე' : 'დღე'
            c.number_field('days', label: 'გეგმიური ვადა', max_digits: 0, after: unitname)
            c.number_field('real_days', label: 'რეალური ვადა', max_digits: 0, after: unitname)

            c.number_field :paid, after: 'GEL'
            c.number_field :remaining, after: 'GEL'
            c.number_field :penalty_first_stage, after: 'GEL'
          end

          c.date_field :send_date
          c.date_field :start_date
          c.date_field :production_date
          c.date_field :end_date 
          c.date_field :plan_end_date if application.apply_duration?
          c.date_field :real_end_date, label: 'რეალური დასრულება' do |real|
            real.action network_change_power_edit_real_date_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png'
          end

          # do |real|
          #   real.action network_change_real_date_url(id: application.id), icon: '/icons/pencil.png' if application.end_date.present?
          # end
          # c.date_field :plan_end_date do |plan|
          #   plan.action network_change_plan_date_url(id: application.id), icon: '/icons/pencil.png' if application.plan_end_date.present?
          # end
        end
      end
      # 2. billing operations
      f.tab title: "ოპერაციები &mdash; <strong>#{application.billing_items.count}</strong>".html_safe, icon: '/icons/edit-list.png' do |t|
        if application.can_send_to_bs?
          t.action network_change_power_send_to_bs_url(id: application.id), label: 'ბილინგში გაგზავნა', icon: '/icons/wand.png', method: 'post', confirm: 'ნამდვილად გინდათ ბილინგში გაგზავნა?'
        end
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

        t.table_field :billing_items_raw, table: { title: 'ბილინგის ოპერაციები აბონენტის გარეშე', icon: '/icons/edit-list.png' } do |operations|
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

            t.text_field 'factura.appl.factura_seria', tag: 'code', label: 'ფაქტურის სერია'
            t.text_field 'factura.appl.factura_number', tag: 'code', label: 'ფაქტურის #'
          end
        end
      end
      # 3. sms messages
      f.tab title: "SMS &mdash; <strong>#{application.messages.count}</strong>".html_safe, icon: '/icons/mobile-phone.png' do |t|
        t.table_field :messages, table: { title: 'SMS შეტყობინებები', icon: '/icons/mobile-phone.png' } do |sms|
          sms.table do |t|
            t.title_action network_send_change_power_sms_url(id: application.id), label: 'SMS გაგზავნა', icon: '/icons/balloon--plus.png'
            t.date_field :created_at, formatter: '%d-%b-%Y %H:%M:%S'
            t.text_field :mobile, tag: 'code'
            t.text_field :message
          end
        end
      end
      # 4. files
      f.tab title: "ფაილები &mdash; <strong>#{application.files.count rescue 0}</strong>".html_safe, icon: '/icons/book-open-text-image.png' do |t|
        t.table_field :files, table: { title: 'ფაილები', icon: '/icons/book-open-text-image.png' } do |files|
          files.table do |t|
            t.title_action network_upload_change_power_file_url(id: application.id), label: 'ახალი ფაილის ატვირთვა', icon: '/icons/upload-cloud.png'
            t.item_action ->(x) { network_delete_change_power_file_url(id: application.id, file_id: x.id) }, icon: '/icons/bin.png', confirm: 'ნამდვილად გინდათ ფაილის წაშლა?', method: 'delete'
            t.text_field 'file.filename', url: ->(x) { x.file.url }, label: 'ფაილი'
          end
        end
      end
      # 5. stages
      f.tab title: "კონტროლი &mdash; <strong>#{application.requests.count}</strong>".html_safe, icon: '/icons/eye.png' do |t|
        t.table_field :requests, table: { title: 'კონტროლი', icon: '/icons/eye.png' } do |requests|
          requests.table do |t|
            t.title_action network_change_power_new_control_item_url(id: application.id), label: 'ახალი საკონტროლო ჩანაწერი', icon: '/icons/eye--plus.png'
            t.item_action ->(x) { network_change_power_edit_control_item_url(id: x.id) }, icon: '/icons/pencil.png'
            t.item_action ->(x) { network_change_power_delete_control_item_url(id: x.id) }, icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვილად გინდათ წაშლა?'
            t.text_field :stage
            t.text_field :type_name, i18n: 'type', tag: 'code'
            t.date_field :date
            t.text_field :description
          end
        end
      end
      # 6. factura
      f.tab title: 'ფაქტურა', icon: '/icons/money.png' do |t|
        if application.can_send_prepayment_factura?
          t.action network_change_power_send_prepayment_factura_prepare_url(id: application.id), icon: '/icons/money--arrow.png', label: 'საავანსო ფაქტურის გაგზავნა', method: 'get'
        end

        t.table_field :facturas, table: { title: 'გამოწერილი ფაქტურები', icon: '/icons/book-open-text-image.png' } do |facturas|
          facturas.table do |factura|
            factura.text_field 'factura_id', tag: 'code', label: '#'
            factura.text_field 'factura_seria', tag: 'code', label: 'ფაქტურის სერია'
            factura.text_field 'factura_number', empty: false, label: 'ფაქტურის #'
            factura.number_field 'amount', after: 'GEL', label: 'თანხა'
          end
        end

        if application.can_send_factura?
          t.action network_change_power_send_factura_url(id: application.id), icon: '/icons/money--arrow.png', label: 'ფაქტურის გაგზავნა', method: 'post', confirm: 'ნამდვილად გინდათ ფაქტურის გაგზავნა?'
        end
        # t.number_field 'amount', after: 'GEL'
        # t.boolean_field 'factura_sent?'
        # t.text_field 'factura_id', tag: 'code'
        # t.complex_field i18n: 'factura_number' do |c|
        #   c.text_field 'factura_seria', tag: 'code', after: '&mdash;'.html_safe
        #   c.text_field 'factura_number', empty: false
        # end
      end
      # gnerc
      f.tab title: 'სემეკი', icon: '/icons/database-cloud.png' do |t|
        t.text_field :gnerc_id, tag: 'code'
        t.text_field :gnerc_status
      end
      # overdue
      f.tab title: 'გადაცილება', icon: '/icons/database-cloud.png' do |t|
       t.table_field :overdue, table: { title: 'გადაცილება', icon: '/icons/database-cloud.png' } do |overdue|
         overdue.table do |over|
          over.title_action network_change_power_new_overdue_item_url(id: application.id), label: 'ახალი გადაცილების ჩანაწერი', icon: '/icons/eye--plus.png'
          over.item_action ->(x) { network_change_power_edit_overdue_item_url(id: x.id) }, icon: '/icons/pencil.png'
          over.item_action ->(x) { network_change_power_delete_overdue_item_url(id: x.id) }, icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვილად გინდათ წაშლა?'

          over.text_field :authority_name
          over.date_field :appeal_date
          over.date_field :deadline
          over.date_field :decision_date
          over.date_field :decision_date
          over.date_field :response_date
          over.text_field :days, label: 'დღეების რაოდენობა'
          over.boolean_field :chosen, required: true do |f|
             f.action ->(x) { network_change_power_toggle_chose_overdue_url(id: x.id) }, label: 'შეცვლა', icon: '/icons/arrow-repeat.png', method: 'post'
           end
        end
       end
      end
      # 7. sys
      f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |t|
        t.complex_field label: 'მომხმარებელი', hint: 'მომხმარებელი, რომელმაც შექმნა ეს განცხადება', required: true do |c|
          c.email_field 'user.email', after: '&mdash;'.html_safe
          c.text_field 'user.full_name'
          c.text_field 'user.mobile'
        end
        # t.timestamps
        # t.number_field 'payment_id', required: true, max_digits: 0
      end
    end
  end
end
