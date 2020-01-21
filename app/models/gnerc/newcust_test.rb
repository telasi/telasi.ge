# -*- encoding : utf-8 -*-
class Gnerc::NewcustTest < ActiveRecord::Base
  establish_connection :gnerc_test
  self.table_name  = 'temo.newcust'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage
end