# -*- encoding : utf-8 -*-
module Network::ApplicationBase
  BASE_PROJECT  = 'project'
  BASE_DOCUMENT = 'document'

  def self.included(base)
    base.field :base_type,   type: String
    base.field :base_number, type: String
    base.field :region,      type: String
  end

  def self.regions; I18n.t('models.application_base.regions').split(',') end
end
