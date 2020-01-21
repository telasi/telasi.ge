# -*- encoding : utf-8 -*-
class Gnerc::Docflow4Test < ActiveRecord::Base
  establish_connection :gnerc_test
  self.table_name  = 'temo.docflow4'
  self.set_integer_columns :confirm, :affirmative, :mediate, :letter_category, :stage
end