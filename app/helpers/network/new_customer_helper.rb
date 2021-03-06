# -*- encoding : utf-8 -*-
module Network::NewCustomerHelper
  def new_customer_table(applications, opts = {})
    table_for applications, title: 'ახალი აბონენტის განცხადებები', icon: '/icons/user--plus.png', collapsible: true do |t|
      t.title_action network_add_new_customer_url, label: 'ახალი განცხადება', icon: '/icons/plus.png'
      t.title_action opts[:xlsx], label: 'ექსელში გადმოწერა', icon: '/icons/document-excel.png' if opts[:xlsx].present?
      t.text_field 'effective_number', i18n: 'number', tag: 'code'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name, url: ->(x) { network_new_customer_url(id: x.id) }
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

      t.complex_field label: 'რეალური დასრულება', required: true do |c|
       c.date_field :end_date
      end 
      t.number_field :days, max_digits: 0, after: 'დღე'
      t.paginate param_name: 'page_new', records: 'ჩანაწერი'
    end
  end

  def prepayment_table(applications, opts = {})
    table_for applications, title: 'განაცხადები ღია საავანსო განცხადებით', icon: '/icons/user--plus.png', collapsible: true do |t|
      t.title_action opts[:xlsx], label: 'ექსელში გადმოწერა', icon: '/icons/document-excel.png' if opts[:xlsx].present?
      t.text_field 'effective_number', i18n: 'number', tag: 'code'
      t.date_field 'start_date', i18n: 'start_date'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name, url: ->(x) { network_new_customer_url(id: x.id) }
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

  def accounting_table(applications, opts = {})
    table_for applications, title: 'ახალი აბონენტის განცხადებები', icon: '/icons/user--plus.png', collapsible: true do |t|
      t.title_action opts[:xlsx], label: 'ექსელში გადმოწერა', icon: '/icons/document-excel.png' if opts[:xlsx].present?
      t.text_field 'effective_number', i18n: 'number', tag: 'code'
      t.text_field 'customer.accnumb', label: 'აბონენტის N', tag: 'code'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name, url: ->(x) { network_new_customer_url(id: x.id) }
      end
      t.number_field :amount, after: 'GEL'
      t.date_field :send_date
      t.date_field :production_date
      t.date_field :plan_end_date
      t.date_field :end_date
      t.number_field :billing_prepayment_total, label: 'მობმული ავანსების თანხა'
      t.number_field :prepayment_percent, label: 'მობმული ავანსის %'
      t.number_field :penalty1, label: 'I ეტაპი'
      t.number_field :penalty2, label: 'II ეტაპი'
      t.number_field :penalty_first_corrected, label: 'დასაბ. თანხა I ეტაპის დარღვევა'
      t.number_field :penalty_second_corrected, label: 'დასაბ. თანხა II ეტაპის დარღვევა'
      
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

  def regions_collection
    h = {}
    Network::ApplicationBase.regions.each do |x|
      h[x] = x
    end
    h
  end

  def app_base_collection
    {
      I18n.t('models.application_base.project')  => Network::ApplicationBase::BASE_PROJECT ,
      I18n.t('models.application_base.document') => Network::ApplicationBase::BASE_DOCUMENT,
    }
  end

  def tp_collection
    h = []
    Billing::Customer.tps.order(:accnumb).each{ |x| h << x.accnumb.to_ka }
    h
  end

  def new_customer_type_collection
    h = {}
    Network::NewCustomerApplication::TYPES.each do |x|
      h[Network::NewCustomerApplication.type_name(x)] = x
    end
    h
  end

  def new_customer_form(application, opts = {})
    forma_for application, title: opts[:title], collapsible: true, icon: opts[:icon] do |f|
      f.tab do |t|
        t.combo_field :type, required: true, autofocus: true, collection: new_customer_type_collection, empty: false
        t.combo_field :customer_type_id, required: true, collection: customer_type_collection, empty: false
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
        t.combo_field :region, collection: regions_collection, empty: '--'
        t.text_field  :address, required: true, width: 500
        t.text_field  :work_address, width: 500
        t.text_field  :address_code #, required: true
        t.combo_field :bank_code, collection: banks, empty: '-- აარჩიეთ ბანკი --' #empty: true, required: true
        t.text_field  :bank_account, width: 300 #, required: true
        t.combo_field :voltage, collection: voltage_collection, empty: false, required: true
        t.number_field :power, after: 'kWh', width: 100, required: true
        t.number_field :abonent_amount, width: 50, required: true
        t.text_field :mtnumb, label: 'მრიცხველი'
        # t.boolean_field :need_resolution, required: true
        t.combo_field :duration, collection: duration_collection, empty: false, required: true, label: 'შესრულების ხანგრძლიობა'
        t.text_field :substation, width: 500
        t.text_field :notes, width: 500
        t.text_field :oqmi
        t.text_field :proeqti
        # t.boolean_field :micro, label: 'მიკროსიმძლავრის ელექტროსადგურის გამანაწილებელ ქსელზე მიერთების მოთხოვნა'
        # t.number_field :microstation_number, label: 'მიკრო სიმძლავრის ელექტროსადგურების რაოდენობა'
        # t.combo_field :micro_source, label: 'მიკროსიმძლავრის ელექტროსადგურის პირველადი ენერგიის წყარო', collection: micro_source_collection, empty: '--'
        t.combo_field :micro_voltage, collection: voltage_collection, empty: false, label: 'მიკროსიმძლავრის მოთხოვნილი ძაბვა' 
        t.number_field :micro_power, after: 'kWh', width: 100, label: 'მიკროსიმძლავრის მოთხოვნილი სიმძლავრე'
        t.combo_field :micro_power_source, collection: micro_power_source_collection, empty: false, label: 'მიკროსიმძლავრის პირველადი ენერგიის წყარო' 
        # t.text_field :micro_model, label: 'მიკროსიმძლავრის ელექტროსადგურის მწარმოებელი და მოდელი (თუ ცნობილია)'
        # t.text_field :micro_scheme, label: 'მიკროსიმძლავრის ელექტროსადგურის ქსელში ჩართვის სქემა:', collection: { 'სინქრონული' => 0, 'ინვერტორით' => 1}
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
    when 'gnerc' then 7
    when 'overdue' then 8
    when 'sys' then 9
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
      f.title_action network_delete_new_customer_url(id: application.id), label: 'განცხადების წაშლა', icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვვილად გინდათ ამ განცხადების წაშლა?' if (show_actions and ( current_user.admin or current_user.cancelaria_user? ))
      # 1. general
      f.tab title: 'ძირითადი', icon: '/icons/user.png' do |t|
        t.action network_new_customer_print_url(id: application.id, format: 'pdf'), label: 'განაცხადი', icon: '/icons/printer.png' if show_actions
        t.action network_new_customer_print_cost_form_url(id: application.id, format: 'pdf'), label: 'აღრიცხვის ფორმა', icon: '/icons/report.png' if show_actions
        t.action network_new_customer_sign_url(id: application.id), label: 'ხელმოწერა', icon: '/icons/edit-signiture.png'
        #if Network::ACTIVATE_SDWEB and not application.signed
        #  t.action network_new_customer_sign_url(id: application.id), label: 'ხელმოწერა', icon: '/icons/edit-signiture.png'
        #end
        t.action network_new_customer_paybill_url(id: application.id), label: 'საგ. დავალება', icon: '/icons/clipboard-task.png' if show_actions
        t.action network_edit_new_customer_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png' if (show_actions and app_editable?(application))
        t.action network_change_dates_url(id: application.id), label: 'თარიღების შეცვლა', icon: '/icons/alarm-clock--pencil.png'
        application.transitions.each do |status|
          t.action network_change_new_customer_status_url(id: application.id, status: status), label: Network::NewCustomerApplication.status_name(status), icon: Network::NewCustomerApplication.status_icon(status) if show_actions
        end
        t.text_field 'type_name', required: true, i18n: 'type'
        t.text_field 'customer_type_name', required: true, i18n: 'customer_type_id'
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
        t.boolean_field :need_factura, required: true do |f|
          f.action network_new_customer_toggle_need_factura_url(id: application.id), label: 'შეცვლა', icon: '/icons/arrow-repeat.png', method: 'post', confirm: ' ნამდვილად გინდათ ფაქტურის საჭიროების შეცვლა?'
        end
        t.boolean_field :show_tin_on_print, required: true
        t.boolean_field :personal_use, required: true
        t.email_field :email
        t.text_field :formatted_mobile, required: true
        t.text_field :region
        t.text_field :address, required: true, hint: 'განმცხადებლის მისამართი'
        t.complex_field i18n: 'work_address', required: true do |c|
          c.text_field 'address_code', tag: 'code', empty: false
          c.text_field 'work_address', empty: false
        end
        t.complex_field label: 'საბანკო ანგარიში', required: true do |c|
          c.text_field :bank_code, tag: 'code'
          c.text_field :bank_account
        end
        t.text_field :abonent_amount, required: true
        t.complex_field label: 'ძაბვა / სიმძლავრე', required: true do |c|
          c.text_field :voltage, tag: 'code'
          c.text_field :unit, after: '/'
          c.number_field :power, after: 'კვტ'
        end
        t.text_field :duration_name, label: 'შესრულების ხანგრძლიობა', required: true
        t.text_field :substation
        t.text_field :notes
        t.text_field :oqmi
        t.text_field :proeqti
        t.col2 do |c|
          c.text_field 'stage', label: 'მიმდინარე ეტაპი'
          c.complex_field label: 'ბილინგის აბონენტი' do |c|
            c.text_field 'customer.accnumb', tag: 'code', empty: false
            c.text_field 'customer.custname'
            c.text_field 'customer.commercial', empty: false, before: '&mdash;'.html_safe
          end
          c.text_field :mtnumb, label: 'მრიცხველი'
          if application.micro || application.tariff_multiplier || application.add_price_for_customer_amount?
            t.complex_field label: 'ღირებულება', required: true do |c|
              c.text_field :amount, tag: 'code', after: '= '
              c.text_field :std_amount, tag: 'code', hint: 'სტანდარტული თანხა'
              c.text_field 'tariff_multiplier.multiplier', tag: 'code', before: ' * ' if application.tariff_multiplier
              c.text_field :micro_amount, tag: 'code', before: ' + ' if application.micro
              c.text_field :customer_amount_price, before: ' + ', tag: 'code' if application.add_price_for_customer_amount?
            end
          else
            c.number_field :amount, after: 'GEL'
          end

          unitname = application.use_business_days ? 'სამუშაო დღე' : 'დღე'
          if application.total_overdue_days.present? && application.total_overdue_days > 0
            t.complex_field label: 'ვადა', required: true do |c|
              c.number_field('total_days', tag: 'code', after: '= ', max_digits: 0)
              c.number_field('days', tag: 'code', max_digits: 0)
              c.number_field('total_overdue_days', before: ' + ', tag: 'code', max_digits: 0, after: unitname)
            end
          else
            c.number_field('days', label: 'გეგმიური ვადა', max_digits: 0, after: unitname)
          end
          c.number_field('real_days', label: 'რეალური ვადა', max_digits: 0, after: unitname)

          c.number_field :paid, after: 'GEL'
          c.number_field :remaining, after: 'GEL'
          c.number_field :penalty_first_stage, after: 'GEL'
          c.number_field :penalty_second_stage, after: 'GEL'
          c.number_field :penalty_third_stage, after: 'GEL'
          c.date_field :send_date
          c.date_field :start_date
          c.date_field :production_date
          c.date_field :end_date
          c.date_field :plan_end_date
          # c.date_field :real_end_date, label: 'რეალური დასრულება' do |real|
          #   real.action network_new_customer_edit_real_date_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png'
          # end
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

            t.text_field 'factura.appl.factura_seria', tag: 'code', label: 'ფაქტურის სერია'
            t.text_field 'factura.appl.factura_number', tag: 'code', label: 'ფაქტურის #'
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
        if application.can_send_prepayment_factura?
          t.action network_new_customer_send_prepayment_factura_prepare_url(id: application.id), icon: '/icons/money--arrow.png', label: 'საავანსო ფაქტურის გაგზავნა', method: 'get', confirm: 'ნამდვილად გინდათ საავანსო ფაქტურის გაგზავნა?' if show_actions
        end

        if application.can_send_correcting1_factura?
          t.action network_new_customer_send_correcting1_factura_url(id: application.id), icon: '/icons/money--arrow.png', label: 'კორექტირებული I ეტაპის ფაქტურის გაგზავნა', method: 'post', confirm: 'ნამდვილად გინდათ საავანსო ფაქტურის გაგზავნა?' if show_actions
        end

        if application.can_send_correcting2_factura?
          t.action network_new_customer_send_correcting2_factura_url(id: application.id), icon: '/icons/money--arrow.png', label: 'კორექტირებული II ეტაპის ფაქტურის გაგზავნა', method: 'post', confirm: 'ნამდვილად გინდათ საავანსო ფაქტურის გაგზავნა?' if show_actions
        end

        t.table_field :facturas, table: { title: 'გამოწერილი ფაქტურები', icon: '/icons/book-open-text-image.png' } do |facturas|
          facturas.table do |factura|
            factura.text_field 'factura_id', tag: 'code', label: '#'
            factura.text_field 'factura_seria.to_ka', tag: 'code', label: 'ფაქტურის სერია'
            factura.text_field 'factura_number', empty: false, label: 'ფაქტურის #'
            factura.text_field 'category_name', label: 'ტიპი'
            factura.number_field 'amount', after: 'GEL', label: 'თანხა'
          end
        end

        if application.can_send_factura?
          t.action network_new_customer_send_factura_url(id: application.id), icon: '/icons/money--arrow.png', label: 'ფაქტურის გაგზავნა', method: 'post', confirm: 'ნამდვილად გინდათ ფაქტურის გაგზავნა?' if show_actions
        end
        # t.number_field 'effective_amount', after: 'GEL'
        # t.boolean_field 'factura_sent?'
        # t.text_field 'factura_id', tag: 'code'
        # t.complex_field i18n: 'factura_number' do |c|
        #   c.text_field 'factura_seria', tag: 'code', after: '&mdash;'.html_safe
        #   c.text_field 'factura_number', empty: false
        # end
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
      # gnerc
       f.tab title: 'სემეკი', icon: '/icons/database-cloud.png' do |t|
         t.text_field :gnerc_id, tag: 'code'
         t.text_field :gnerc_status
       end
      # overdue
      f.tab title: 'გადაცილება', icon: '/icons/database-cloud.png' do |t|
       t.table_field :overdue, table: { title: 'გადაცილება', icon: '/icons/database-cloud.png' } do |overdue|
         overdue.table do |over|
          over.title_action network_new_customer_new_overdue_item_url(id: application.id), label: 'ახალი გადაცილების ჩანაწერი', icon: '/icons/eye--plus.png'
          over.item_action ->(x) { network_new_customer_edit_overdue_item_url(id: x.id) }, icon: '/icons/pencil.png'
          over.item_action ->(x) { network_new_customer_delete_overdue_item_url(id: x.id) }, icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვილად გინდათ წაშლა?'

          over.text_field :authority_name
          over.date_field :appeal_date
          over.date_field :deadline
          over.date_field :decision_date
          over.date_field :response_date
          over.text_field :days, label: 'დღეების რაოდენობა'
          over.boolean_field :chosen, required: true do |f|
             f.action ->(x) { network_new_customer_toggle_chose_overdue_url(id: x.id) }, width: 200, label: 'შეცვლა', icon: '/icons/arrow-repeat.png', method: 'post'
          end
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
        #t.timestamps
        t.number_field 'payment_id', required: true, max_digits: 0
        t.boolean_field 'online', required: true
      end
    end
  end

  def sms_message_form(message, opts = {})
    forma_for message, title: opts[:title], icon: opts[:icon], collapsible: true do |f|
        f.text_field 'message', required: true, autofocus: true, width: 800 if opts[:no_message].blank?
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

  def overdue_item_form(item, opts = {})
    if item.source.class == Network::NewCustomerApplication
      cancel_url = network_new_customer_url(id: item.source.id, tab: 'overdue')
    elsif item.source.class == Network::ChangePowerApplication
      cancel_url = network_change_power_url(id: item.source.id, tab: 'overdue')
    else
      raise 'unknown class'
    end
    forma_for item, title: opts[:title], collapsible: true, icon: opts[:icon] do |f|
      f.combo_field 'authority', collection: GnercConstants::OVERDUE_ADM_AUTHORITY.invert, empty: false, required: true, i18n: 'authority'
      f.date_field 'appeal_date', required: true
      f.complex_field label: 'სამუშაო დღეები', hint: 'დავთვალოთ სამუშაო დღეები თუ კალენდარული?', required: true do |c|
          c.boolean_field 'business_days', required: true
      end
      f.complex_field label: 'კანონმდებლობით დადგენილი ვადა', required: true do |c|
          c.boolean_field 'check_days'
          c.number_field 'planned_days', required: true
          c.boolean_field 'check_date'
          c.date_field 'deadline', required: true
      end
      f.date_field 'decision_date', required: true
      f.date_field 'response_date', required: true
      f.boolean_field 'chosen', required: true
      f.submit 'შენახვა'
      f.cancel_button cancel_url
    end
  end

  def new_customer_template(application)
    
  end
end
