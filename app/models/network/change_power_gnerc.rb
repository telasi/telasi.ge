# -*- encoding : utf-8 -*-
module Network::ChangePowerGnerc

  GNERC_VOLTAGE_220 = '0.220'
  GNERC_VOLTAGE_380 = '0.380'
  GNERC_VOLTAGE_610 = '6-10'

  def table_by_service
    case self.service
      when Network::ChangePowerApplication::SERVICE_METER_SETUP
        'Gnerc::MeterSetup'
      when Network::ChangePowerApplication::SERVICE_CHANGE_POWER 
        'Gnerc::ChangePower'
      when Network::ChangePowerApplication::SERVICE_MICRO_POWER
        'Gnerc::MicroPower'
       when Network::ChangePowerApplication::SERVICE_TECH_CONDITION
        'Gnerc::TechCondition'
    end
  end

  # def table_by_service
  #   'Gnerc::Docflow4'
  # end

  def gnerc_status
    return if self.number.blank?
    newcust = self.table_by_service.constantize.where(letter_number: self.number).first
    return I18n.t('models.network_new_customer_application.gnerc_statuses.not_sent') unless newcust
    queue_stage1 = Gnerc::SendQueue.where(service: self.table_by_service.split('::')[1], service_id: newcust.id, stage: 1).first
    if queue_stage1.blank?
      return I18n.t('models.network_new_customer_application.gnerc_statuses.not_sent')
    else
      
      if queue_stage1.sent_at.blank?
        I18n.t('models.network_new_customer_application.gnerc_statuses.waiting')
      else
        queue_stage2 = Gnerc::SendQueue.where(service: self.table_by_service.split('::')[1], service_id: newcust.id, stage: 2).first
        if queue_stage2.present?
          queue_stage2.sent_at.blank? ? I18n.t('models.network_new_customer_application.gnerc_statuses.answered_ready') : I18n.t('models.network_new_customer_application.gnerc_statuses.answered')
        else
          I18n.t('models.network_new_customer_application.gnerc_statuses.sent')
        end
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
                   applicant_address:     self.work_address[0..254],
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   voltage:               requested_voltage,
                   request_package:       requested_package(self.voltage, self.power),
                   power:                 self.power,
                   appeal_date:           self.send_date,
                   attach_9_1:            content,
                   attach_9_1_filename:   file.file.filename,
                   unique_code:           unique_code
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorker.perform_async("appeal", 9, parameters)
  end

  def send_meter_setup_2
    request_status = case self.status
                      when Network::BaseClass::STATUS_CONFIRMED then 1
                      when Network::BaseClass::STATUS_IN_BS     then 1
                      when Network::BaseClass::STATUS_CANCELED  then 2
                      when Network::BaseClass::STATUS_USER_DECLINED then 2
                    end

    parameters = { letter_number:         self.number,
                   request_status:        request_status,
                   sms:                   get_message }
    
    if request_status == 2
      file = self.files.select{ |x| x.file.filename[0..2] == Network::ChangePowerApplication::GNERC_DEF_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      else
        file = self.files.select{ |x| x.file.filename[0..4] == Network::ChangePowerApplication::GNERC_REFAB_FILE }.first
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
      end

      parameters.merge!({ attach_9_2:          content,
                          attach_9_2_filename: file.file.filename })
    else
      parameters.merge!({ abonent_number:  self.customer.accnumb }) 
    end

    # attach_9_5
    GnercWorker.perform_async("answer", 9, parameters)
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
                   applicant_address:     self.work_address[0..254],
                   location:              1,
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   current_voltage:       current_voltage,
                   requested_voltage:     requested_voltage,
                   current_volume:        self.old_power,
                   requested_volume:      self.power,
                   changing_technical_condition: self.changing_technical_condition ? 1 : 0,
                   appeal_date:           self.send_date,
                   attach_10_1:           content,
                   attach_10_1_filename:  file.file.filename
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorker.perform_async("appeal", 10, parameters)
  end

  def send_change_power_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CANCELED      then 1
                   when Network::BaseClass::STATUS_USER_DECLINED then 2
                   when Network::BaseClass::STATUS_CONFIRMED     then 3
                   when Network::BaseClass::STATUS_IN_BS         then 3
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
    GnercWorker.perform_async("answer", 10, parameters)
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
                   applicant_address:     self.work_address[0..254],
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   micro_power_source:    self.micro_power_source,
                   voltage:               current_voltage,
                   requested_volume:      requested_package(self.voltage, self.power),
                   power:                 self.power,
                   appeal_date:           self.send_date,
                   attach_11_1:           content,
                   attach_11_1_filename:  file.file.filename
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if self.abonent_amount > 1

    GnercWorker.perform_async("appeal", 11, parameters)
  end

  def send_micro_power_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CANCELED      then 1
                   when Network::BaseClass::STATUS_USER_DECLINED then 2
                   when Network::BaseClass::STATUS_CONFIRMED     then 3
                   when Network::BaseClass::STATUS_IN_BS         then 3
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

    GnercWorker.perform_async("answer", 11, parameters)
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
                   applicant_address:     self.work_address[0..254],
                   cadastral_number:      self.address_code,
                   customer_type_id:      self.customer_type_id,
                   voltage:               current_voltage,
                   power:                 self.power,
                   appeal_date:           self.send_date,
                   attach_12_1:           content,
                   attach_12_1_filename:  file.file.filename
                 }

    parameters.merge!({ abonent_amount: self.abonent_amount }) if customer_request == 2

    GnercWorker.perform_async("appeal", 12, parameters)
  end

  def send_tech_condition_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CONFIRMED then 1
                   when Network::BaseClass::STATUS_IN_BS     then 1
                   when Network::BaseClass::STATUS_CANCELED  then 2
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

    if response_id == 1
      raise I18n.t('ტექპირობის ნომერი') if self.tech_condition_cns.blank?
      parameters.merge!({ technical_condition: self.tech_condition_cns }) 
    end

    GnercWorker.perform_async("answer", 12, parameters)
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

  def send_res(file)
    content = File.read(file.file.file.file)
    content = Base64.encode64(content)
    case self.service 
      when 9
        parameters = { letter_number:       self.number,
                   attach_9_2:          content,
                   attach_9_2_filename: file.file.filename,
                   request_status:      2 }
      when 12
        parameters = { letter_number:       self.number,
                   attach_12:          content,
                   attach_12_filename: file.file.filename,
                   response_id:      2 }
    end

    GnercWorker.perform_async("answer", self.service, parameters)
  end

  private 

  def checks_for_gnerc_2
    case self.service
      when Network::ChangePowerApplication::SERVICE_METER_SETUP
        true
      when Network::ChangePowerApplication::SERVICE_CHANGE_POWER 
        true
      when Network::ChangePowerApplication::SERVICE_MICRO_POWER
        true
       when Network::ChangePowerApplication::SERVICE_TECH_CONDITION
        check_tech_condition_2
    end
  end

  def check_tech_condition_2
    response_id = case self.status
                   when Network::BaseClass::STATUS_CONFIRMED then 1
                   when Network::BaseClass::STATUS_IN_BS     then 1
                   when Network::BaseClass::STATUS_CANCELED  then 2
                 end
    if response_id == 1
      raise I18n.t('შეიყვანეთ ტექპირობის ნომერი') if self.tech_condition_cns.blank?
    end
  end

  def find_main_file
    file = self.files.select{ |x| x.file.filename[0..11] == Network::ChangePowerApplication::GNERC_SIGNATURE_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)
    else 
      raise I18n.t('ატვირთეთ ChangePower ფაილი')
    end
    return [ file, content ]
  end

  def get_unique_code
    techcondition = Network::ChangePowerApplication.where(number: self.tech_condition_cns).first
    #raise I18n.t('Tech condition is not sent') if ( techcondition.blank? || techcondition.gnerc_id.blank? )
    techcondition.gnerc_id if techcondition.present?
  end

  def get_message
    message = self.messages.where(id: self.sms_response).first.message if self.messages.where(id: self.sms_response).first
    message || ' '
  end


  # ====================================== TEST ==========================================



end