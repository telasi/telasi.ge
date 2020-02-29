# -*- encoding : utf-8 -*-
class Gnerc::ChangePower < ActiveRecord::Base
  establish_connection :gnerc
  self.table_name  = 'changepower'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage, :response_id
end