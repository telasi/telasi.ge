# -*- encoding : utf-8 -*-
class Gnerc::MeterSetup < ActiveRecord::Base
  establish_connection :gnerc
  self.table_name  = 'metersetup'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage, :request_status, :response_id
end