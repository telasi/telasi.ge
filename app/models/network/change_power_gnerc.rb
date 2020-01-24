# -*- encoding : utf-8 -*-
module Network::ChangePowerGnerc

  GNERC_VOLTAGE_220 = '0.220'
  GNERC_VOLTAGE_380 = '0.380'
  GNERC_VOLTAGE_610 = '6-10'

  # def table_by_service
  #   case self.service
  #     when Network::ChangePowerApplication::SERVICE_METER_SETUP
  #       'Gnerc::MeterSetup'
  #     when Network::ChangePowerApplication::SERVICE_CHANGE_POWER 
  #       'Gnerc::ChangePower'
  #     when Network::ChangePowerApplication::SERVICE_MICRO_POWER
  #       'Gnerc::MicroPower'
  #      when Network::ChangePowerApplication::SERVICE_TECH_CONDITION
  #       'Gnerc::TechCondition'
  #   end
  # end

  def table_by_service
    'Gnerc::Docflow4'
  end

  def gnerc_status
    return if self.number.blank?
    newcust = self.table_by_service.constantize.where(letter_number: self.number).first
    return I18n.t('models.network_new_customer_application.gnerc_statuses.not_sent') unless newcust
    queue = Gnerc::SendQueue.where(service: self.table_by_service.split('::')[1], service_id: newcust.id, stage: 1).first
    if queue.blank?
      return I18n.t('models.network_new_customer_application.gnerc_statuses.not_sent')
    else
      if self.status < Network::BaseClass::STATUS_COMPLETE
        queue.sent_at.blank? ? I18n.t('models.network_new_customer_application.gnerc_statuses.waiting') : I18n.t('models.network_new_customer_application.gnerc_statuses.sent')
      else
        queue.sent_at.blank? ? I18n.t('models.network_new_customer_application.gnerc_statuses.answered_ready') : I18n.t('models.network_new_customer_application.gnerc_statuses.answered')
      end      
    end
  end

  def send_to_gnerc(stage)
    send_to_gnerc_old(stage)
    if stage == 1
      send_stage_1
    else 
      send_stage_2
    end
  end

  def send_stage_1
    case self.service
      when Network::ChangePowerApplication::SERVICE_METER_SETUP
        send_meter_setup_1
      when Network::ChangePowerApplication::SERVICE_CHANGE_POWER 
        send_change_power_1
      when Network::ChangePowerApplication::SERVICE_MICRO_POWER
        send_micro_power_1
       when Network::ChangePowerApplication::SERVICE_TECH_CONDITION
        send_tech_condition_1
    end
  end

  def send_stage_2
    case self.service
      when Network::ChangePowerApplication::SERVICE_METER_SETUP
         send_meter_setup_2
      when Network::ChangePowerApplication::SERVICE_CHANGE_POWER 
        send_change_power_2
      when Network::ChangePowerApplication::SERVICE_MICRO_POWER
        send_micro_power_2
       when Network::ChangePowerApplication::SERVICE_TECH_CONDITION
        send_tech_condition_2
    end
  end

  def send_meter_setup_1
    if self.abonent_amount > 1 
      customer_request = 2
    else 
      customer_request = 1
    end

    file, content = find_main_file
    unique_code = get_unique_code

    parameters = { letter_number:         self.number,
                   customer_request:      customer_request,
                   applicant:             self.rs_name,
                   identification_number: self.rs_tin,
                   phone_number:          self.mobile,
                   email:                 self.email,
                   applicant_address:     self.address,
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   voltage:               requested_voltage,
                   request_package:       requested_package(self.voltage, self.power),
                   power:                 self.power,
                   appeal_date:           self.start_date,
                   attach_9_1:            content,
                   attach_9_1_filename:   file.file.filename,
                   unique_code:           unique_code
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorkerTest.perform_async("appeal", 9, parameters)
  end

  def send_meter_setup_2
    request_status = case self.status
                      when Network::BaseClass::STATUS_CANCELED then 1
                      when Network::BaseClass::STATUS_CONFIRMED then 2
                    end

    parameters = { letter_number:         self.number,
                   request_status:        request_status,
                   sms:                   get_message }
    
    if response_status == 1
      file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_DEF_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
        parameters.merge!({ attach_9_2:          content,
                            attach_9_2_filename: file.file.filename })
      end
    else
      parameters.merge!({ abonent_number:  self.customer.accnumb }) 
    end

    # attach_9_5
    GnercWorkerTest.perform_async("answer", 9, parameters)
  end

  def send_change_power_1
    if self.abonent_amount > 1 
      customer_request = 2
    else 
      customer_request = 1
    end

    file, content = find_main_file

    parameters = { letter_number:         self.number,
                   customer_request:      customer_request,
                   applicant:             self.rs_name,
                   abonent_number:        self.real_customer.accnumb,
                   identification_number: self.rs_tin,
                   phone_number:          self.mobile,
                   email:                 self.email,
                   applicant_address:     self.address,
                   location:              1,
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   current_voltage:       current_voltage,
                   requested_voltage:     requested_voltage,
                   current_volume:        self.old_power,
                   request_volume:        self.power,
                   changing_technical_condition: self.changing_technical_condition ? 1 : 0,
                   appeal_date:           self.start_date,
                   attach_10_1:           content,
                   attach_10_1_filename:  file.file.filename
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorkerTest.perform_async("appeal", 10, parameters)
  end

  def send_change_power_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CANCELED then 1
                   when Network::BaseClass::STATUS_USER_DECLINED then 2
                   when Network::BaseClass::STATUS_CONFIRMED then 3
                 end

    file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_ACT_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)
    else
      file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_DEF_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      else
        file = self.files.select{ |x| x.file.filename[0..4] == Network::ChangePowerApplication::GNERC_REFAB_FILE }.first
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      end
    end

    parameters = { letter_number:      self.number,
                   response_id:        response_id,
                   attach_10:          content,
                   attach_10_filename: file.file.filename,
                   sms_response:       get_message }

    if self.overdue.any?
      parameters.merge!({ admin_authority_overdue: 1 })

      self.overdue.where(chosen: true).each_with_index.map do |over, index|
        suffix = ''
        suffix = "_#{index+1}" if index != 0 
        parameters.merge!(Hash[ 'name_of_adm_authority' + suffix, over.authority,
                                'adm_appeal_date' + suffix, over.appeal_date,
                                'adm_response_deadline' + suffix, over.deadline,
                                'adm_date_of_response' + suffix, over.response_date,
                                'amount_of_overdue' + suffix, over.days ] )
      end
    end
    GnercWorkerTest.perform_async("answer", 10, parameters)
  end

  def send_micro_power_1
    if self.abonent_amount > 1 
      customer_request = 2
    else 
      customer_request = 1
    end

    file, content = find_main_file

    parameters = { letter_number:         self.number,
                   customer_request:      customer_request,
                   applicant:             self.rs_name,
                   abonent_number:        self.real_customer.accnumb,
                   identification_number: self.rs_tin,
                   phone_number:          self.mobile,
                   email:                 self.email,
                   applicant_address:     self.address,
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   micro_power_source:    self.micro_power_source,
                   voltage:               current_voltage,
                   requested_volume:      requested_package(self.voltage, self.power),
                   power:                 self.power,
                   appeal_date:           self.start_date,
                   attach_11_1:           content,
                   attach_11_1_filename:  file.file.filename
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorkerTest.perform_async("appeal", 11, parameters)
  end

  def send_micro_power_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CANCELED then 1
                   when Network::BaseClass::STATUS_USER_DECLINED then 2
                   when Network::BaseClass::STATUS_CONFIRMED then 3
                   else 4
                 end

    file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_ACT_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)
    else
      file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_DEF_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      else
        file = self.files.select{ |x| x.file.filename[0..4] == Network::ChangePowerApplication::GNERC_REFAB_FILE }.first
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      end
    end

    parameters = { letter_number:      self.number,
                   response_id:        response_id,
                   attach_11:          content,
                   attach_11_filename: file.file.filename,
                   sms_response:       get_message }

    GnercWorkerTest.perform_async("answer", 11, parameters)
  end

  def send_tech_condition_1
    if self.abonent_amount > 1 
      customer_request = 2
    else 
      customer_request = 1
    end

    file, content = find_main_file

    parameters = { letter_number:         self.number,
                   customer_request:      customer_request,
                   applicant:             self.rs_name,
                   identification_number: self.rs_tin,
                   phone_number:          self.mobile,
                   email:                 self.email,
                   applicant_address:     self.address,
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   voltage:               current_voltage,
                   power:                 self.power,
                   appeal_date:           self.start_date,
                   attach_12_1:           content,
                   attach_12_1_filename:  file.file.filename
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorkerTest.perform_async("appeal", 12, parameters)
  end

  def send_tech_condition_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CANCELED then 1
                   when Network::BaseClass::STATUS_CONFIRMED then 2
                 end

    file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_ACT_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)
    else
      file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_DEF_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      else
        file = self.files.select{ |x| x.file.filename[0..4] == Network::ChangePowerApplication::GNERC_REFAB_FILE }.first
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      end
    end

    parameters = { letter_number:      self.number,
                   response_id:        response_id,
                   attach_12:          content,
                   attach_12_filename: file.file.filename,
                   sms_response:       get_message }

    parameters.merge!({ technical_condition: self.technical_condition }) if response_id == 1

    GnercWorkerTest.perform_async("answer", 12, parameters)
  end

  def current_voltage
    case self.old_voltage
        when Network::NewCustomerApplication::VOLTAGE_220 then GNERC_VOLTAGE_220
        when Network::NewCustomerApplication::VOLTAGE_380 then GNERC_VOLTAGE_380
        when Network::NewCustomerApplication::VOLTAGE_610 then GNERC_VOLTAGE_610
    end
  end

  def requested_voltage
    case self.voltage
        when Network::NewCustomerApplication::VOLTAGE_220 then GNERC_VOLTAGE_220
        when Network::NewCustomerApplication::VOLTAGE_380 then GNERC_VOLTAGE_380
        when Network::NewCustomerApplication::VOLTAGE_610 then GNERC_VOLTAGE_610
    end
  end

  def requested_package(voltage, power)
    case voltage
      when Network::NewCustomerApplication::VOLTAGE_220 then
        gnerc_requested_volume   = '1-10'
      when Network::NewCustomerApplication::VOLTAGE_380 then
        gnerc_requested_volume = case power
                                  when 1..10 then '1-10'
                                  when 11..30 then '10-30'
                                  when 31..50 then '30-50'
                                  when 51..80 then '50-80'
                                  when 81..100 then '80-100'
                                  when 101..120 then '100-120'
                                  when 121..200 then '120-200'
                                  when 201..320 then '200-320'
                                  when 321..500 then '320-500'
                                  when 501..800 then '500-800'
                                  when 801..1000 then '800-1000'
                                  when 1001..Float::INFINITY then '>1000'
                                end
      when Network::NewCustomerApplication::VOLTAGE_610 then
        gnerc_requested_volume = case power
                                  when 1..500 then '1-500'
                                  when 501..1000 then '500-1000'
                                  when 1001..Float::INFINITY then '>1000'
                                end
    end
    gnerc_requested_volume
  end

  private 

  def find_main_file
    file = self.files.select{ |x| x.file.filename[0..11] == Network::ChangePowerApplication::GNERC_SIGNATURE_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)
    end
    return [ file, content ]
  end

  def get_unique_code
    techcondition = Network::ChangePowerApplication.where(number: self.tech_condition_cns).first
    return I18n.t('Tech condition is not sent') if ( techcondition.blank? || techcondition.gnerc_id.blank? )
    techcondition.gnerc_id
  end

  def get_message
    message = self.messages.where(id: self.sms_response).first.message if self.messages.where(id: self.sms_response).first
    message || ' '
  end


  # ====================================== TEST ==========================================



end