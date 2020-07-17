# -*- encoding : utf-8 -*-
class Network::NewCustomerApplicationTemplate

	TEMPLATE_DIR = 'data/network/template'

	attr_writer :application

	def initialize(application)
		@application = application
	end

	def print
		Sys::PdfTemplate.render_to_content(get_template, generate_parameters)
		# Sys::PdfTemplate.send_to_client(get_template, @application.id.to_s + '.pdf', generate_parameters)
	end

	def print_cost_form
		Sys::PdfTemplate.render_to_content(get_cost_template, cost_parameters)
	end

	private 

	def get_cost_template
		File.join(Rails.root, "#{TEMPLATE_DIR}", 'cost_form.pdf')
	end

	def get_template
		file = if @application.abonent_amount == 1
			     if @application.micro
			    	'new_customer_micro.pdf'
			     else 	
					'new_customer.pdf'
				 end
				else
				 if @application.micro 
				 	'new_customer_multi_micro.pdf'
				 else
				 	'new_customer_multi.pdf'
				 end
				end
		File.join(Rails.root, "#{TEMPLATE_DIR}", file)
	end

	def generate_parameters
	  if @application.abonent_amount == 1
	     if @application.micro
	    	return new_customer_micro_parameters
	     else 	
			return new_customer_parameters
		 end
		else
		 if @application.micro
	    	return new_customer_multi_micro_parameters
	     else 	
			return new_customer_multi_parameters
		 end			
		end
	end

	def main_parameters
		params = {}
		params[:created_date_day] = @application.created_at.day
		params[:created_date_month] = month_name(@application.created_at.month)
		params[:created_date_year] = @application.created_at.year
		params[:filled_date_day] = @application.created_at.day
		params[:filled_date_month] = month_name(@application.created_at.month)
		params[:filled_date_year] = @application.created_at.year
		params[:number] = @application.number
		params[:rs_name] = @application.rs_name
		params[:rs_tin] = @application.rs_tin
		params[:address] = @application.address
		params[:mob_op] = @application.mobile[0..2]
		params[:mob_mobile] = @application.mobile[3..8]
		params[:mail_start], params[:mail_domain] = @application.email.split('@')
		params[:bank] = "#{@application.bank_code}, #{@application.bank_name}, #{@application.bank_account}"
		params[:work_address] = "#{@application.work_address || @application.address}"
		params[:address_code] = @application.address_code
		if @application.customer.present?
			params[:customer_name] = @application.customer.to_s
			params[:customer_taxid] = @application.customer.taxid
		end
		params[:low_voltage] = 'Yes' unless @application.voltage != '6/10'
		params[:high_voltage] = 'Yes' unless @application.voltage == '6/10'
		params[:voltage_220] = 'Yes' unless @application.voltage == '220'
		params[:voltage_380] = 'Yes' unless @application.voltage == '380'
		params[:power] = @application.power
		params[:amount] = @application.amount
		params[:factura_yes] = 'Yes' unless @application.need_factura
		params[:factura_no] = 'Yes' if @application.need_factura
		return params
	end

	def new_customer_parameters
		params = main_parameters
		return params
    end

    def new_customer_micro_parameters
		params = main_parameters
		params[:std_amount] = @application.std_amount
		params[:micro_amount] = @application.micro_amount
		return params
    end

    def new_customer_multi_parameters
    	params = main_parameters
    	params[:abonent_amount] = @application.abonent_amount
    	return params
    end

    def new_customer_multi_micro_parameters
    	params = main_parameters
    	params[:abonent_amount] = @application.abonent_amount
    	params[:micro_amount] = @application.micro_amount
    	return params
    end

    def cost_parameters
		params = {}
		params[:number] = @application.number
		params[:advance] = @application.billing_prepayment_total
		params[:rs_name] = @application.rs_name
		params[:start_date] = @application.start_date.strftime('%d.%m.%Y') if @application.start_date
		params[:power] = @application.power
		params[:days] = @application.days
		params[:plan_end_date] = @application.plan_end_date.strftime('%d.%m.%Y') if @application.plan_end_date
		params[:end_date] = @application.end_date.strftime('%d.%m.%Y') if @application.end_date
		params[:total_penalty] = @application.total_penalty
		params[:amount] = @application.amount
		if @application.penalty_first_stage > 0
			params[:penalty1_start_date] = params[:start_date]
			params[:penalty1_end_date] = params[:end_date]
			params[:penalty1_first_stage] = @application.penalty_first_stage
		end
		if @application.penalty_second_stage > 0
			params[:penalty2_first_stage] = @application.penalty_first_stage
		end
		if @application.penalty_second_stage > 0
			params[:penalty2_first_stage] = @application.penalty_first_stage
		end
		params[:customer_accnumb] = @application.customer.try(:accnumb)

		stage = Network::Stage.where(numb: 4).first
		request = @application.requests.where(stage: stage).first
		params[:commission_date] = request.date.strftime('%d.%m.%Y') if request.present?
		params[:today] = Time.now.strftime('%d.%m.%Y')
		return params
	end

	def month_name(month)
	  case month
		  when 1 then 'იანვარი'
		  when 2 then 'თებერვალი'
		  when 3 then 'მარტი'
		  when 4 then 'აპრილი'
		  when 5 then 'მაისი'
		  when 6 then 'ივნისი'
		  when 7 then 'ივლისი'
		  when 8 then 'აგვისტო'
		  when 9 then 'სექტემბერი'
		  when 10 then 'ოქტომბერი'
		  when 11 then 'ნოემბერი'
		  when 12 then 'დეკემბერი'
	  end
	end
end