# -*- encoding : utf-8 -*-
class Tender::Tenderuser

   ORG_TYPES = [ 'OT_PHYSIC', 'OT_LEGAL']

   include Mongoid::Document
   include Mongoid::Timestamps

   belongs_to :user,      class_name: 'Sys::User'           # მომხმარებელი
   has_many   :downloads, class_name: 'Tender::Download'

   field :organization_type, 	type: String
   field :organization_name,  type: String
   field :director_name, 	   type: String
   field :fact_address, 		type: String
   field :legal_address, 		type: String
   field :phones,				   type: String
   field :work_email,  			type: String
   field :rs_tin,             type: String
   field :rs_foreigner,       type: Mongoid::Boolean, default: false

   validates :rs_tin, presence: { message: I18n.t('tender.empty') }
   validates :rs_tin, uniqueness: { message: I18n.t('tender.rs_tin_exist') }
   validates :organization_name, presence: { message: I18n.t('tender.empty') }
   validates :director_name, presence: { message: I18n.t('tender.empty') }
   validates :fact_address, presence: { message: I18n.t('tender.empty') }
   validates :legal_address, presence: { message: I18n.t('tender.empty') }
   validates :phones, presence: { message: I18n.t('tender.empty') }
   validates :work_email, presence: { message: I18n.t('tender.empty') }

   def organization_type_name
      I18n.t("tender.organization_types.#{self.organization_type}")
   end

end