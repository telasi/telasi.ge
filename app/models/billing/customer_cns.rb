# -*- encoding : utf-8 -*-
class Billing::CustomerCns< ActiveRecord::Base
  self.table_name  = 'bs.customer_cns'

  self.set_integer_columns :power_type, :status
end