# -*- encoding : utf-8 -*-
class Gnerc::TechCondition < ActiveRecord::Base
  establish_connection :gnerc_test
  self.table_name  = 'techcondition'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage, :response_id
end