# -*- encoding : utf-8 -*-
class Customer::DocumentType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name_ka, type: String
  field :description_ka, type: String
  field :name_ru, type: String
  field :description_ru, type: String

  field :owner_personal, type: Mongoid::Boolean
  field :owner_not_personal, type: Mongoid::Boolean
  field :rent_personal, type: Mongoid::Boolean
  field :rent_not_personal, type: Mongoid::Boolean

  def name
    case I18n.locale.to_s
    when 'ru' then self.name_ru
    else self.name_ka end
  end

  def description
    case I18n.locale.to_s
    when 'ru' then self.description_ru
    else self.description_ka end
  end
end
