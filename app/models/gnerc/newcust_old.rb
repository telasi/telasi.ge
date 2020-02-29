# -*- encoding : utf-8 -*-
class Gnerc::NewcustOld < ActiveRecord::Base
  establish_connection :gnerc_old
  self.table_name  = 'semek.newcust'
  self.set_integer_columns :confirmation, :building, :abonent_amount, :stage
end