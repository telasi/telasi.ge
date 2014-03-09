# -*- encoding : utf-8 -*-
class Site::Cachefield < ActiveRecord::Base
  self.table_name  = 'telasi.cache_field'
  self.primary_key = :cid
end