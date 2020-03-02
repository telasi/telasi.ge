# -*- encoding : utf-8 -*-
class Gnerc::Docflow4Old < ActiveRecord::Base
  establish_connection :gnerc_old
  self.table_name  = 'semek.docflow4'
  self.set_integer_columns :confirm, :affirmative, :mediate, :letter_category, :stage
end