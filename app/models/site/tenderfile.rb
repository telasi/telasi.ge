# -*- encoding : utf-8 -*-
class Site::Tenderfile < ActiveRecord::Base
  self.table_name  = 'telasi.field_data_field_fileexists'
  self.primary_keys = [:entity_type, :deleted, :entity_id, :language, :delta]

  before_save :before_save

  private

  def before_save
    	@tenderrevision = Site::Tenderfilerevision.where(entity_type: self.entity_type, deleted: self.deleted, entity_id: self.entity_id, language: self.language, delta: self.delta).first || Site::Tenderfilerevision.new(entity_type: self.entity_type, bundle: self.bundle, deleted: self.deleted, entity_id: self.entity_id, revision_id: self.revision_id, language: self.language, delta: self.delta)
     	@tenderrevision.field_fileexists_value = self.field_fileexists_value
  	  @tenderrevision.save

  	  @cache = Site::Cachefield.where(cid: "field:node:#{self.entity_id}").first
  	  @cache.destroy if @cache
  end
end
