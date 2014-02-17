# -*- encoding : utf-8 -*-
class Site::Node < ActiveRecord::Base
  self.table_name  = 'telasi.node'
  self.primary_key = :nid
  self.inheritance_column = :inheritance_column

  def created_at; Time.at(self.created) end
  def updated_at; Time.at(self.updated) end

  def content_type; Site::ContentType.where(entity_type: 'node', bundle: self.type, entity_id: self.nid).first end
  def content_thumbnail; Site::ContentThumbnail; Site::ContentThumbnail.where(entity_type: 'node', bundle: self.type, entity_id: self.nid).first end
  def content; Site::Content.where(entity_type: 'node', bundle: self.type, entity_id: self.nid).first end
  def file_uploaded?; Tender::Tender.where(nid: self.nid).first end

  def thumbnail
    c_thumbnail = self.content_thumbnail
    c_thumbnail.file if c_thumbnail
  end

  def thumbnail_small_url
    t = self.thumbnail
    t.uri.gsub('public://', 'http://telasi.ge/sites/default/files/styles/single_page/public/') if t
  end

  def tenderno
    reg = /№(.*?)\s/.match(self.title)
    if reg;reg[1];end
  end
end
