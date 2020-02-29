# -*- encoding : utf-8 -*-
class Gnerc::MicroPower < ActiveRecord::Base
  establish_connection :gnerc
  self.table_name  = 'micropower'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage, :response_id
end