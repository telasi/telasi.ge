# -*- encoding : utf-8 -*-
class Network::OverdueItem
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :source, polymorphic: true

  field :authority, type: Integer
  field :appeal_date, type: Date
  field :planned_days, type: Integer
  field :deadline, type: Date
  field :decision_date, type: Date
  field :response_date, type: Date
  field :days, type: Integer
  field :chosen, type: Mongoid::Boolean, default: false
  field :business_days, type: Mongoid::Boolean, default: false
  field :check_days, type: Mongoid::Boolean, default: false

  validates :authority, presence: { message: 'Required' }
  validates :appeal_date, presence: { message: 'Required' }
  validates :deadline, presence: { message: 'Required' }
  validates :response_date, presence: { message: 'Required' }
  # validates :days, presence: { message: 'Required' }
  validate :max_chosen_items
  before_save :calculate_days
  after_save :calculate_plan_end_date

  def authority_name; GnercConstants::OVERDUE_ADM_AUTHORITY[self.authority] end

  private 

  def max_chosen_items
  	if self.chosen && self.source.overdue.where(chosen: true).count >= GnercConstants::OVERDUE_MAX_ITEMS
  		self.errors.add(:chosen, 'max 4')
  	end
  end

  def calculate_plan_end_date
  	self.source.save
  end

  def calculate_days
    if self.business_days
      self.days = self.appeal_date.business_days_until(self.response_date)
    else
      self.days = self.response_date - self.appeal_date
    end
  end

end
