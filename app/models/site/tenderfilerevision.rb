# -*- encoding : utf-8 -*-
class Site::Tenderfilerevision < ActiveRecord::Base
  self.table_name  = 'telasi.field_revision_field_fileexists'
  self.primary_keys = [:entity_type, :deleted, :entity_id, :language, :delta]
end