# -*- encoding : utf-8 -*-
class BackgroundJobProcessor
  include Sidekiq::Worker
  include Sys::BackgroundJobConstants

  def perform(id)
    job = Sys::BackgroundJob.find(id)
    unless job.completed?
      begin
        job.path = process_job(job)
        job.success = true
       rescue Exception => ex
        job.failed = true
        job.trace = ex.backtrace.join("\n")
      end
      job.save
    end
  end

  private

  def process_job(job)
    case job.name
    when NETWORK_NEWCUSTOMER_TO_XLSX then network_new_customers_to_xlsx(job)
    end
  end

  def with_path(job)
    path = '/tmp/' + job.id + '.xlsx'
    yield path
    path
  end

  def network_new_customers_to_xlsx(job)
    apps = Network::NewCustomerController.filter_applications( (eval(job.data).symbolize_keys rescue nil) )
    with_path(job) do |path|
      Axlsx::Package.new do |xlsx_package|
        wb = xlsx_package.workbook
        style_header = wb.styles.add_style b: true, alignment: { horizontal: :center }
        wb.add_worksheet(name: "new-customers") do |sheet|
          sheet.add_row [
            'ნომერი', 'სტატუსი', 'საიდ.კოდი', 'დასახელება', 'დღგ-ს გადამხდელი',
            "საყოფაც?", "ფაქტურა?",
            "გამოგზ.თარიღი", "დაწყ. თარიღი", "რეალრ. დასრ.", "გეგმიურ. დასრულ.",
            'ელ.ფოსტა', 'მობილური', 'რეგიონი', 'იურ.მისამართი', 'საკ.კოდი', 'ფაქტ.მისამართი',
            'ბანკი', 'ანგარიშის #',
            "აბ.#", "აბონენტი",
            "თანხა", "ვადა (დღე)", "დარჩენილია", "ჯარიმა I", "ჯარიმა II", "ჯარიმა III",
          ]
          apps.each do |app|
            sheet.add_row [app.number, app.status_name, app.rs_tin, app.rs_name, app.vat_name,
              app.personal_use ? 'კი' : 'არა', app.need_factura ? 'კი' : 'არა',
              app.send_date, app.start_date, app.end_date, app.plan_end_date,
              app.email, app.mobile, app.region, app.address, app.address_code, app.work_address,
              "#{app.bank_name} (#{app.bank_code})", app.bank_account,
              app.customer ? app.customer.accnumb.to_ka : "", app.customer ? app.customer.custname.to_ka : "",
              app.amount, app.days, app.remaining, app.penalty1, app.penalty2, app.penalty3,
            ]
          end
        end
        xlsx_package.serialize(path)
      end
    end
  end
end
