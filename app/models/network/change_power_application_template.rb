# -*- encoding : utf-8 -*-
class Network::ChangePowerApplicationTemplate

	TEMPLATE_DIR = 'data/network/template'

	attr_writer :application

	def initialize(application)
		@application = application
	end

	def print
		Sys::PdfTemplate.render_to_content(get_template, generate_parameters)
	end

	def print_cost_form
		Sys::PdfTemplate.render_to_content(get_cost_template, cost_parameters)
	end

	def self.implemented_types
		[Network::ChangePowerApplication::TYPE_SPLIT, Network::ChangePowerApplication::TYPE_CHANGE_POWER, Network::ChangePowerApplication::TYPE_MICROPOWER]
	end

	private 

	def get_cost_template
		File.join(Rails.root, "#{TEMPLATE_DIR}", 'cost_form.pdf')
	end

	def get_template
		file = case @application.type 
			     when Network::ChangePowerApplication::TYPE_SPLIT then 'change_power_split.pdf'
			     when Network::ChangePowerApplication::TYPE_CHANGE_POWER then 'change_power_rise.pdf'
			     when Network::ChangePowerApplication::TYPE_MICROPOWER then 'change_power_micro.pdf'
				end
		File.join(Rails.root, "#{TEMPLATE_DIR}", file)
	end

	def generate_parameters
		case @application.type 
	     when Network::ChangePowerApplication::TYPE_SPLIT then return change_power_split_parameters
	     when Network::ChangePowerApplication::TYPE_CHANGE_POWER then return change_power_rise_parameters
	     when Network::ChangePowerApplication::TYPE_MICROPOWER then return change_power_micro_parameters
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

		params[:accnumb] = @application.customer.accnumb.to_ka if @application.customer

		params[:old_low_v] = 'Yes' unless @application.old_voltage != '6/10'
		params[:old_high_v] = 'Yes' unless @application.old_voltage == '6/10'
		params[:old_v_220] = 'Yes' unless @application.old_voltage == '220'
		params[:old_v_380] = 'Yes' unless @application.old_voltage == '380'
		params[:old_power] = @application.old_power

		params[:low_v] = 'Yes' unless @application.voltage != '6/10'
		params[:high_v] = 'Yes' unless @application.voltage == '6/10'
		params[:v_220] = 'Yes' unless @application.voltage == '220'
		params[:v_380] = 'Yes' unless @application.voltage == '380'
		params[:power] = @application.power

		params[:amount] = @application.amount
		params[:factura_yes] = 'Yes' unless @application.need_factura
		params[:factura_no] = 'Yes' if @application.need_factura
		return params
	end

	def change_power_split_parameters
		params = main_parameters
		return params
    end

    def change_power_rise_parameters
		params = main_parameters
		return params
    end

    def change_power_micro_parameters
		params = main_parameters
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
		stage = Network::Stage.where(numb: 4).first
		request = @application.requests.where(stage: stage).first
		params[:commission_date] = request.date.strftime('%d.%m.%Y') if request.present?
		params[:customer_accnumb] = @application.customer.try(:accnumb)
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