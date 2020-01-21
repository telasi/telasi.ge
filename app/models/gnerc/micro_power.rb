# -*- encoding : utf-8 -*-
class Gnerc::MicroPower < ActiveRecord::Base
  establish_connection :gnerc_test
  self.table_name  = 'micropower'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage
end