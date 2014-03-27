# -*- encoding : utf-8 -*-
class Customer::DocumentType
  include Mongoid::Document
  include Mongoid::Timestamps
  include Customer::Constants

  field :name_ka,   type: String
  field :name_ru,   type: String
  field :category,  type: String, default: CAT_PERSONAL
  field :ownership, type: String, default: OWN_OWNER
  field :required,  type: Mongoid::Boolean, default: true

  validates :name_ka, presence: { message: 'ჩაწერეთ ქართული დასახელება' }
  validates :name_ru, presence: { message: 'ჩაწერეთ რუსული დასახელება' }
  validates :category, presence: { message: 'აარჩიეთ კატეგორია' }
  validates :ownership, presence: { message: 'აარჩიეთ მფლობელი' }

  def name
    case I18n.locale.to_s
    when 'ru' then self.name_ru
    else self.name_ka end
  end
end
