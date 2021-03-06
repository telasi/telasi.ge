# -*- encoding : utf-8 -*-
class Tender::Tender
   include Mongoid::Document
   include Mongoid::Timestamps

   after_save :aftersave
   before_destroy :beforedestroy

   field    :nid,      type: Integer
   field    :tenderno, type: String 
   has_many :files,  	 class_name: 'Sys::File', as: 'mountable'

  private

   def aftersave
    @tenders = Site::Node.where(tnid: self.nid)

    @tenders.each do |t|

     	@tender = Site::Tenderfile.where(entity_type: 'node', deleted: 0, entity_id: t.nid, language: 'und', delta: 0).first || Site::Tenderfile.new(entity_type: 'node', bundle: 'news', deleted: 0, revision_id: t.nid, entity_id: t.nid, language: 'und', delta: 0)
     	@tender.field_fileexists_value = 1
  	  @tender.save

    end
   end

   def beforedestroy
    @tenders = Site::Node.where(tnid: self.nid)

    @tenders.each do |t|

     	@tender = Site::Tenderfile.where(entity_type: 'node', deleted: 0, entity_id: self.nid, language: 'und', delta: 0).first
     	if @tender 
     	  @tender.field_fileexists_value = 0
  	    @tender.save
      end
    end
   end

end
