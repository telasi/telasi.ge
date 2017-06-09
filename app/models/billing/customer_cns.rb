# -*- encoding : utf-8 -*-
class Billing::CustomerCns< ActiveRecord::Base
  self.establish_connection :bs

  self.table_name  = 'bs.customer_cns'
  self.set_integer_columns :status
end