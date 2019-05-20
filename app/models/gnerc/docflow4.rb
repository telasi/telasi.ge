# -*- encoding : utf-8 -*-
class Gnerc::Docflow4 < ActiveRecord::Base
  establish_connection :gnerc
  self.table_name  = 'docflow4'
  self.set_integer_columns :confirm, :affirmative, :mediate, :letter_category, :stage
end