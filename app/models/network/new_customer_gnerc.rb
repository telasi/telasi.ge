# -*- encoding : utf-8 -*-
module Network::NewCustomerGnerc

  GNERC_VOLTAGE_220 = '0.220'
  GNERC_VOLTAGE_380 = '0.380'
  GNERC_VOLTAGE_610 = '6-10'

  def send_to_gnerc(stage)
    send_to_gnerc_old(stage)
    if stage == 1
      send_stage_1
    else 
      send_stage_2
    end
  end

  def gnerc_status
    return if self.number.blank?
    newcust = Gnerc::Newcust.where(letter_number: self.number).first
    return I18n.t('models.network_new_customer_application.gnerc_statuses.not_sent') unless newcust
    queue = Gnerc::SendQueue.where(service: 'Newcust', service_id: newcust.id, stage: 1).first
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

  def send_stage_1
    file = self.files.select{ |x| x.file.filename[0..11] == Network::NewCustomerApplication::GNERC_SIGNATURE_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)

      tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power, self.start_date)
      gnerc_power = "#{tariff.power_from+1}-#{tariff.power_to}"

      case self.voltage
        when Network::NewCustomerApplication::VOLTAGE_220 then gnerc_voltage = GNERC_VOLTAGE_220
        when Network::NewCustomerApplication::VOLTAGE_380 then gnerc_voltage = GNERC_VOLTAGE_380
        when Network::NewCustomerApplication::VOLTAGE_610 then gnerc_voltage = GNERC_VOLTAGE_610
      end

      gnerc_requested_volume = requested_volume

      raise "error" if ( self.type.blank? || self.type == 0 )

      parameters = { letter_number:         self.number,
                     customer_request:      self.type,
                     customer_type_id:      self.customer_type_id,
                     applicant:             self.rs_name,
                     identification_number: self.rs_tin,
                     phone_number:          self.mobile,
                     email:                 self.email,
                     applicant_address:     self.work_address,
                     location:              1,
                     cadastral_number:      self.address_code,
                     voltage:               gnerc_voltage,
                     requested_volume:      gnerc_requested_volume,
                     power:                 self.power,
                     appeal_date:           self.send_date,
                     attach_7_1:            content,
                     attach_7_1_filename:   file.file.filename
                   }

      if self.abonent_amount > 2
        parameters.merge!({ building:            1, 
                            abonent_amount:      self.abonent_amount })
      end

      if [Network::NewCustomerApplication::TYPE_MICRO, Network::NewCustomerApplication::TYPE_MULTI_MICRO].include?(self.type)
        gnerc_micro_voltage, gnerc_requested_volume2 = requested_volume_micro
        parameters.merge!({ micro_power_source: self.micro_power_source,
                            voltage_2:          gnerc_micro_voltage, 
                            requested_volume_2: gnerc_requested_volume2,
                            power_2:            gnerc_micro_power })
      end

      GnercWorker.perform_async("appeal", 7, parameters)
    end
  end

  def send_stage_2
    response_id = case self.status
                    when Network::BaseClass::STATUS_CANCELED then 1
                    when Network::BaseClass::STATUS_USER_DECLINED then 2
                    when Network::BaseClass::STATUS_CONFIRMED then 3
                    when Network::BaseClass::STATUS_IN_BS     then 3
                  end

    parameters = { response_id:         response_id,
                   letter_number:       self.number,
                   actual_date:         Time.now }

    file = self.files.select{ |x| x.file.filename[0..2] == Network::NewCustomerApplication::GNERC_ACT_FILE }.first
    if file.present?
      content = File.read(file.file.file.file)
      content = Base64.encode64(content)
      parameters.merge!({ attach_7:          content,
                          attach_7_filename: file.file.filename,
                          sms_response:      self.messages.where(id: self.sms_response).first.message,
                          sms_date:          self.messages.where(id: self.sms_response).first.created_at })
    else
      file = self.files.select{ |x| x.file.filename[0..2] == Network::NewCustomerApplication::GNERC_DEF_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
        parameters.merge!({ attach_7:          content,
                            attach_7_filename: file.file.filename })
      else
        file = self.files.select{ |x| x.file.filename[0..4] == Network::NewCustomerApplication::GNERC_REFAB_FILE }.first
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
        parameters.merge!({ attach_7:          content,
                            attach_7_filename: file.file.filename })
      end
    end

    if response_id == 3 &&
       [Network::NewCustomerApplication::TYPE_INDIVIDUAL, 
        Network::NewCustomerApplication::TYPE_MICRO, 
        Network::NewCustomerApplication::TYPE_SEPARATED].include?(self.type)

       parameters.merge!({ abonent_number:  self.customer.accnumb })
    end

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

    GnercWorker.perform_async("answer", 7, parameters)
  end

  def requested_volume
    case self.type
        when Network::NewCustomerApplication::TYPE_INDIVIDUAL, 
             Network::NewCustomerApplication::TYPE_MULTI_ABONENT, 
             Network::NewCustomerApplication::TYPE_MICRO, 
             Network::NewCustomerApplication::TYPE_MULTI_MICRO then 

          case self.voltage
            when Network::NewCustomerApplication::VOLTAGE_220 then
              gnerc_requested_volume   = '1-10'
            when Network::NewCustomerApplication::VOLTAGE_380 then
              gnerc_requested_volume = case self.power
                                        when 1..10 then '1-10'
                                        when 11..30 then '10-30'
                                        when 31..50 then '30-50'
                                        when 51..80 then '50-80'
                                        when 81..100 then '80-100'
                                        when 101..120 then '100-120'
                                        when 121..150 then '120-150'
                                        when 151..200 then '150-200'
                                        when 201..320 then '200-320'
                                        when 321..500 then '320-500'
                                        when 501..800 then '500-800'
                                        when 801..1000 then '800-1000'
                                        when 1001..Float::INFINITY then '>1000'
                                      end
            when Network::NewCustomerApplication::VOLTAGE_610 then
              gnerc_requested_volume = case self.power
                                        when 1..500 then '1-500'
                                        when 501..1000 then '500-1000'
                                        when 1001..1500 then '1000-1500'
                                        when 1501..2000 then '1500-2000'
                                        when 2001..3000 then '2000-3000'
                                        when 3001..5000 then '3000-5000'
                                      end
          end

          when Network::NewCustomerApplication::TYPE_SEPARATED then 

            case self.voltage
              when Network::NewCustomerApplication::VOLTAGE_220 then
                gnerc_requested_volume   = '1-10'
              when Network::NewCustomerApplication::VOLTAGE_380 then
                gnerc_requested_volume = case self.power
                                          when 1..10 then '1-10'
                                          when 11..30 then '10-30'
                                          when 31..50 then '30-50'
                                          when 51..80 then '50-80'
                                          when 81..100 then '80-100'
                                          when 101..120 then '100-120'
                                          when 121..150 then '120-150'
                                          when 151..200 then '150-200'
                                          when 201..320 then '200-320'
                                          when 321..500 then '320-500'
                                          when 501..800 then '500-800'
                                          when 801..1000 then '800-1000'
                                          when 1001..Float::INFINITY then '>1000'
                                        end
              when Network::NewCustomerApplication::VOLTAGE_610 then
                gnerc_requested_volume = case self.power
                                          when 1..500 then '1-500'
                                          when 501..1000 then '500-1000'
                                          when 1001..Float::INFINITY then '>1000'
                                        end
            end
      end
    gnerc_requested_volume
  end

  def requested_volume_micro
    case self.micro_voltage
      when Network::NewCustomerApplication::VOLTAGE_220 then
        gnerc_micro_voltage = GNERC_VOLTAGE_220
        gnerc_requested_volume2 = '1-10'
      when Network::NewCustomerApplication::VOLTAGE_380 then
        gnerc_micro_voltage = GNERC_VOLTAGE_380
        gnerc_requested_volume2 = case self.micro_power
                                    when 1..10 then '1-10'
                                    when 11..30 then '10-30'
                                    when 31..50 then '30-50'
                                    when 51..80 then '50-80'
                                    when 81..100 then '80-100'
                                    when 101..120 then '100-120'
                                    when 121..150 then '120-150'
                                    when 151..200 then '150-200'
                                    when 201..320 then '200-320'
                                    when 321..500 then '320-500'
                                    when 501..800 then '500-800'
                                    when 801..1000 then '800-1000'
                                    when 1001..Float::INFINITY then '>1000'
                                  end
       when Network::NewCustomerApplication::VOLTAGE_610 then
        gnerc_micro_voltage = GNERC_VOLTAGE_610
        gnerc_requested_volume2 = case self.micro_power
                                    when 1..500 then '1-500'
                                    when 501..1000 then '500-1000'
                                    when 1001..Float::INFINITY then '>1000'
                                  end
    end
    return gnerc_micro_voltage, gnerc_requested_volume2
  end

  #======================================= TEST =======================================

  def send_to_gnerc_old(stage)
    if stage == 1
      # file = self.files.select{ |x| x.file.filename[0..11] == Network::NewCustomerApplication::GNERC_SIGNATURE_FILE }.first
      # if file.present?
      #   content = File.read(file.file.file.file)
      #   content = Base64.encode64(content)

      #   tariff = Network::NewCustomerTariff.tariff_for(self.voltage, self.power, self.start_date)
      #   gnerc_power = "#{tariff.power_from+1}-#{tariff.power_to}"

      #   case self.voltage
      #     when Network::NewCustomerApplication::VOLTAGE_220 then
      #       gnerc_voltage = GNERC_VOLTAGE_220
      #     when Network::NewCustomerApplication::VOLTAGE_380 then
      #       gnerc_voltage = GNERC_VOLTAGE_380
      #      when Network::NewCustomerApplication::VOLTAGE_610 then
      #       gnerc_voltage = GNERC_VOLTAGE_610
      #   end

      #   parameters = { letter_number:       self.number,
      #                  applicant:           self.rs_name,
      #                  applicant_address:   self.address,
      #                  voltage:             gnerc_voltage,
      #                  power:               gnerc_power,
      #                  appeal_date:         self.start_date,
      #                  attach_7_1:          content,
      #                  attach_7_1_filename: file.file.filename 
      #                }

      #   if self.abonent_amount > 2
      #     parameters.merge!({ building:            1, 
      #                         abonent_amount:      self.abonent_amount })
      #   end

      #   if self.micro
      #     case self.micro_voltage
      #       when Network::NewCustomerApplication::VOLTAGE_220 then
      #         gnerc_micro_voltage = GNERC_VOLTAGE_220
      #         gnerc_micro_power   = '1..10'
      #       when Network::NewCustomerApplication::VOLTAGE_380 then
      #         gnerc_micro_voltage = GNERC_VOLTAGE_380
      #         gnerc_micro_power   = case self.micro_power
      #                                 when 1..10 then '1..10'
      #                                 when 11..30 then '11..30'
      #                                 when 31..50 then '31..50'
      #                                 when 51..80 then '51..80'
      #                                 when 81..100 then '81..100'
      #                                 when 101..120 then '101..120'
      #                                 when 121..150 then '121..150'
      #                                 when 151..200 then '151..200'
      #                                 when 201..320 then '201..320'
      #                                 when 321..500 then '321..500'
      #                                 when 501..800 then '501..800'
      #                                 when 801..1000 then '801..1000'
      #                                 when 1001..Float::INFINITY then '>1000'
      #                               end
      #        when Network::NewCustomerApplication::VOLTAGE_610 then
      #         gnerc_micro_voltage = GNERC_VOLTAGE_610
      #         gnerc_micro_power   = case self.micro_power
      #                                 when 1..500 then '1..500'
      #                                 when 501..1000 then '501..1000'
      #                                 when 1001..1500 then '1001..1500'
      #                                 when 1501..2000 then '1501..2000'
      #                                 when 2001..3000 then '2001..3000'
      #                                 when 3001..5000 then '3001..5000'
      #                                 when 5001..Float::INFINITY then '>5000'
      #                               end
      #     end

      #     parameters.merge!({ voltage_2:    gnerc_micro_voltage, 
      #                         power_2:      gnerc_micro_power })

      #   end

      #   GnercWorkerOld.perform_async("appeal", 7, parameters)
      # end
    else 
      file = self.files.select{ |x| x.file.filename[0..2] == Network::NewCustomerApplication::GNERC_ACT_FILE }.first
      if file.present?
        content = File.read(file.file.file.file)
        content = Base64.encode64(content)
        parameters = { letter_number:       self.number,
                       attach_7_2:          content,
                       attach_7_2_filename: file.file.filename,
                       confirmation:        1 
                     }
      else
        file = self.files.select{ |x| x.file.filename[0..2] == Network::NewCustomerApplication::GNERC_DEF_FILE }.first
        if file.present?
          content = File.read(file.file.file.file)
          content = Base64.encode64(content)
          parameters = { letter_number:       self.number,
                         attach_7_4:          content,
                         attach_7_4_filename: file.file.filename
                       }
        else
          file = self.files.select{ |x| x.file.filename[0..4] == Network::NewCustomerApplication::GNERC_REFAB_FILE }.first
          content = File.read(file.file.file.file)
          content = Base64.encode64(content)
          parameters = { letter_number:           self.number,
                         refuse_abonent:          content,
                         refuse_abonent_filename: file.file.filename
                       }
        end
      end
      GnercWorkerOld.perform_async("answer", 7, parameters)
    end
  end

end