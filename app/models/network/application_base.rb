module Network::ApplicationBase
  BASE_NONE = 'none'
  BASE_PROJ = 'project'
  BASE_DOC  = 'document'

  def self.included(base)
    base.field :base_type,   type: String, default: Network::ApplicationBase::BASE_NONE
    base.field :base_number, type: String
    base.field :region,      type: String
  end

  def self.regions; I18n.t('models.application_base.regions').split(',') end
end
