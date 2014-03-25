# -*- encoding : utf-8 -*-
class Customer::DocumentType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name_ka, type: String
  field :name_ru, type: String

  field :owner_personal, type: Mongoid::Boolean
  field :owner_not_personal, type: Mongoid::Boolean
  field :rent_personal, type: Mongoid::Boolean
  field :rent_not_personal, type: Mongoid::Boolean

  validates :name_ka, presence: { message: 'ჩაწერეთ ქართული დასახელება' }
  validates :name_ru, presence: { message: 'ჩაწერეთ რუსული დასახელება' }

  def name
    case I18n.locale.to_s
    when 'ru' then self.name_ru
    else self.name_ka end
  end
end
