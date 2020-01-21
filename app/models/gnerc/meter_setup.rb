# -*- encoding : utf-8 -*-
class Gnerc::MeterSetup < ActiveRecord::Base
  establish_connection :gnerc_test
  self.table_name  = 'metersetup'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage
end