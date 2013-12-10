# -*- encoding : utf-8 -*-
module Network::ChangePowerHelper
  def change_power_table(applications)
    table_for applications, title: 'სიმძლავრის ცვლილების განცხადებები', icon: '/icons/user--pencil.png', collapsible: true do |t|
      t.title_action network_add_change_power_url, label: 'ახალი განცხადება', icon: '/icons/plus.png'
      t.text_field 'number', i18n: 'number', tag: 'code'
      t.complex_field i18n: 'status_name', required: true do |c|
        c.image_field :status_icon
        c.text_field :status_name
      end
      t.complex_field i18n: 'rs_name' do |c|
        c.text_field :rs_tin, tag: 'code'
        c.text_field :rs_name, url: ->(x) { network_change_power_url(id: x.id) }
      end
      t.number_field :amount, after: 'GEL'
      t.number_field :days, max_digits: 0, after: 'დღე'
      t.paginate param_name: 'page_change', records: 'ჩანაწერი'
    end
  end

  def change_power_form(application, opts = {})
    forma_for application, title: opts[:title], collapsible: true, icon: opts[:icon] do |f|
      f.tab do |t|
        t.text_field  :number, required: true, autofocus: true
        t.text_field  :rs_tin, required: true
        # t.boolean_field :rs_vat_payer, required: true
        t.combo_field :vat_options, collection: vat_collection, empty: false, i18n: 'vat_name', required: true
        t.text_field  :mobile, required: true
        t.email_field :email
        t.text_field  :address, required: true, width: 500
        t.text_field  :work_address, required: true, width: 500
        t.text_field  :address_code, required: true
        t.combo_field :bank_code, collection: banks, empty: false, required: true
        t.text_field  :bank_account, required: true, width: 300
        f.select_field :customer, select_customer_url, label: 'ბილინგის აბონენტი', required: true, search_width: 900
        t.combo_field :old_voltage, collection: voltage_collection, empty: false, required: true
        t.number_field :old_power, after: 'kWh', width: 100, required: true
        t.combo_field :voltage, collection: voltage_collection, empty: false, required: true
        t.number_field :power, after: 'kWh', width: 100, required: true
      end
      f.submit (opts[:submit] || opts[:title])
      f.bottom_action opts[:cancel_url], label: 'გაუქმება', icon: '/icons/cross.png'
    end
  end

  private

  def selected_change_power_tab
    case params[:tab]
    when 'sms' then 1
    when 'files' then 2
    when 'sys' then 3
    else 0 end
  end

  public

  def change_power_view(application, opts = {})
    view_for application, title: 'განცხადების თვისებები', collapsible: true, icon: '/icons/user--pencil.png', selected_tab: selected_change_power_tab do |f|
      f.title_action network_delete_change_power_url(id: application.id), label: 'განცხადების წაშლა', icon: '/icons/bin.png', method: 'delete', confirm: 'ნამდვვილად გინდათ ამ განცხადების წაშლა?'
      # 1. general
      f.tab title: 'ძირითადი', icon: '/icons/user.png' do |t|
        # t.action network_new_customer_print_url(id: application.id, format: 'pdf'), label: 'განცხადების ბეჭდვა', icon: '/icons/printer.png'
        # t.action network_new_customer_paybill_url(id: application.id, format: 'pdf'), label: 'საგ/დავ ბეჭდვა', icon: '/icons/printer.png'
        t.action network_edit_change_power_url(id: application.id), label: 'შეცვლა', icon: '/icons/pencil.png'
        application.transitions.each do |status|
          t.action network_change_change_power_status_url(id: application.id, status: status), label: Network::ChangePowerApplication.status_name(status), icon: Network::ChangePowerApplication.status_icon(status)
        end
        t.text_field 'number', required: true, tag: 'code'
        t.complex_field i18n: 'status_name', required: true do |c|
          c.image_field :status_icon
          c.text_field :status_name
        end
        t.complex_field i18n: 'rs_name', required: true do |c|
          c.text_field :rs_tin, tag: 'code'
          c.text_field :rs_name, url: ->(x) { network_change_power_url(id: x.id) }
        end
        t.text_field :vat_name, required: true
        t.email_field :email
        t.text_field :mobile, required: true
        t.text_field :address, required: true, hint: 'განმცხადებლის მისამართი'
        t.complex_field i18n: 'work_address', required: true do |c|
          c.text_field 'address_code', tag: 'code'
          c.text_field 'work_address', empty: false
        end
        t.complex_field label: 'საბანკო ანგარიში', required: true do |c|
          c.text_field :bank_code, tag: 'code'
          c.text_field :bank_account
        end
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
        
        t.col2 do |c|
          c.complex_field label: 'ბილინგის აბონენტი', required: true do |c|
            c.text_field 'customer.accnumb', tag: 'code'
            c.text_field 'customer.custname'
          end
          c.number_field :amount, after: 'GEL'
          # c.number_field :paid, after: 'GEL'
          # c.number_field :remaining, after: 'GEL'
          c.date_field :send_date
          c.date_field :start_date
          c.date_field :end_date # do |real|
          #   real.action network_change_real_date_url(id: application.id), icon: '/icons/pencil.png' if application.end_date.present?
          # end
          # c.date_field :plan_end_date do |plan|
          #   plan.action network_change_plan_date_url(id: application.id), icon: '/icons/pencil.png' if application.plan_end_date.present?
          # end
        end
      end
      # 2. sms messages
      f.tab title: "SMS &mdash; <strong>#{application.messages.count}</strong>".html_safe, icon: '/icons/mobile-phone.png' do |t|
        t.table_field :messages, table: { title: 'SMS შეტყობინებები', icon: '/icons/mobile-phone.png' } do |sms|
          sms.table do |t|
            t.title_action network_send_new_customer_sms_url(id: application.id), label: 'SMS გაგზავნა', icon: '/icons/balloon--plus.png'
            t.date_field :created_at, formatter: '%d-%b-%Y %H:%M:%S'
            t.text_field :mobile, tag: 'code'
            t.text_field :message
          end
        end
      end
      # 3. files
      f.tab title: "ფაილები &mdash; <strong>#{application.files.count rescue 0}</strong>".html_safe, icon: '/icons/book-open-text-image.png' do |t|
        # t.table_field :files, table: { title: 'ფაილები', icon: '/icons/book-open-text-image.png' } do |files|
        #   files.table do |t|
        #     t.title_action network_upload_new_customer_file_url(id: application.id), label: 'ახალი ფაილის ატვირთვა', icon: '/icons/upload-cloud.png'
        #     t.item_action ->(x) { network_delete_new_customer_file_url(id: application.id, file_id: x.id) }, icon: '/icons/bin.png', confirm: 'ნამდვილად გინდათ ფაილის წაშლა?', method: 'delete'
        #     t.text_field 'file.filename', url: ->(x) { x.file.url }, label: 'ფაილი'
        #   end
        # end
      end
      # 4. sys
      f.tab title: 'სისტემური', icon: '/icons/traffic-cone.png' do |t|
        t.complex_field label: 'მომხმარებელი', hint: 'მომხმარებელი, რომელმაც შექმნა ეს განცხადება', required: true do |c|
          c.email_field 'user.email', after: '&mdash;'.html_safe
          c.text_field 'user.full_name'
          c.text_field 'user.mobile'
        end
        t.timestamps
        # t.number_field 'payment_id', required: true, max_digits: 0
      end
    end
  end
end
