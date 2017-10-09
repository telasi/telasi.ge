# -*- encoding : utf-8 -*-
class Gnerc::Newcust < ActiveRecord::Base
  establish_connection :gnerc
  self.table_name  = 'newcust'
  self.set_integer_columns :confirmation
end