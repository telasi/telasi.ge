# -*- encoding : utf-8 -*-
module Sys
  class User
    include KA
    include Mongoid::Document
    include Mongoid::Timestamps
    # store_in collection: 'users'
    # mount_uploader :avatar, AvatarUploader

    field :email,                 type: String
    field :email_confirmed,       type: Boolean
    field :email_confirm_hash,    type: String
    field :hashed_password,       type: String
    field :salt,                  type: String
    field :password_restore_hash, type: String
    field :admin,                 type: Mongoid::Boolean
    field :active,                type: Mongoid::Boolean

    field :first_name, type: String
    field :last_name,  type: String
    field :mobile,     type: String

    field :searchable,     type: Mongoid::Boolean
    field :email_visible,  type: Mongoid::Boolean
    field :mobile_visible, type: Mongoid::Boolean

    # თანამშრომლის ობიექტი ამ მომხმარებლისთვის.
    # has_many :employees
    # has_many :stories, :as => :author

    index({ email: 1 }, { unique: true })
    # index(first_name: 1, last_name: 1)

    validates :email, uniqueness: { message: I18n.t('models.sys_user.errors.email_is_taken') }
    validates :email, email: { message: I18n.t('models.sys_user.errors.illegal_email') }
    validates :password, confirmation: { message: I18n.t('models.sys_user.errors.password_not_match') }
    validates :first_name, presence: { message: I18n.t('models.sys_user.errors.empty_first_name') }
    validates :last_name, presence: { message: I18n.t('models.sys_user.errors.empty_last_name') }
    validates :mobile, mobile: { message: I18n.t('models.sys_user.errors.illegal_mobile') }
    validate :password_definition

    before_create :user_before_create
    before_save :user_before_save

    def self.current_user; Thread.current[:current_user] end
    def self.current_user=(usr); Thread.current[:current_user] = usr end
    def full_name; "#{first_name} #{last_name}" end
    def self.encrypt_password(password, salt); Digest::SHA1.hexdigest("#{password}dimitri#{salt}") end
    def self.generate_hash(user); Digest::MD5.hexdigest("#{Time.now}#{rand(20111111)/11.0}#{user.email}") end
    def to_s; full_name end
    attr_accessor :password_confirmation
    attr_reader :password

    def password=(pwd)
      @password = pwd
      return if pwd.blank?
      self.salt = "#{self.object_id}#{rand 1000}"
      self.hashed_password = User.encrypt_password(self.password, self.salt)
      self.password_restore_hash = nil
    end

    # Authenticate user (even inactive)
    # using given email and password.
    def self.authenticate(email, password)
      user = User.where(:email => email).first
      user = nil if user and user.hashed_password != User.encrypt_password(password, user.salt)
      user
    end

    # This method is used for confirming user email.
    # `confirm_hash` parameter is used 
    def confirm_email!(confirm_hash)
      if self.email_confirmed
        true
      elsif self.email_confirm_hash == confirm_hash
        self.email_confirmed = true
        self.email_confirm_hash = nil
        self.save
      else
        false
      end
    end

    # When user requires password restore this hash is generated for
    # identifing the user.
    def generate_restore_hash!
      self.password_restore_hash = User.generate_hash(self)
      self.save!
    end

    # # არის თუ არა ეს მომხმარებელი ამ ორგანიზაციის წევრი?
    # def employee?(org)
    #   self.employees.map{|e| e.organization}.include?(org)
    # end

    # # მომხმარებლის პარამეტრის დაყენება.
    # def set(key, val)
    #   pref = UserPreference.where(:user_id => self._id, :key => key).first
    #   pref = UserPreference.new(:user => self, :key => key) unless pref
    #   pref.value = val
    #   pref.save
    # end

    # # მომხმარებლის პარამეტრის მიღება.
    # def get(key)
    #   pref = UserPreference.where(:user_id => self._id, :key => key).first
    #   pref.value if pref
    # end

    # # ეძებს მომხმარებელს სახელის და გვარის მიხედვით.
    # def self.by_name(q)
    #   self.search_by_q(q, :first_name, :last_name)
    # end

    # # ეძებს მოცემული ტექსტის მიხედვით.
    # def self.by_query(q)
    #   self.search_by_q(q, :first_name, :last_name, :email, :mobile)
    # end

    private

    def password_definition
      if hashed_password.blank?
        errors.add(:password, I18n.t('models.sys_user.errors.empty_password'))
      end
    end

    def user_before_create
      first = User.count == 0
      if first
        self.admin = true
        self.email_confirmed = true
        self.email_confirm_hash = nil
      else
        confirmed = (not Telasi::CONFIRM_ON_REGISTER)
        self.admin = false
        self.email_confirmed = confirmed
        self.email_confirm_hash = confirmed ? nil : User.generate_hash(self)
      end
      self.searchable = true
      self.email_visible = true
      self.mobile_visible = false
      self.active = true
    end

    def user_before_save
      self.mobile = compact_mobile(self.mobile)
    end
  end
end