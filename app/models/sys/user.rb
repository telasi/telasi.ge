# -*- encoding : utf-8 -*-
module Sys
  class User
    include KA
    include Mongoid::Document
    include Mongoid::Timestamps

    EXPIRATION_MINUTES = 60
    NEXT_RESEND_IN_MINUTES = 1

    field :email,                 type: String
    field :email_confirmed,       type: Mongoid::Boolean
    field :email_confirm_hash,    type: String
    field :sms_confirm_code,      type: String
    field :sms_code_expires_at,   type: DateTime
    field :sms_next_resend_at,    type: DateTime
    field :hashed_password,       type: String
    field :salt,                  type: String
    field :password_restore_hash, type: String
    field :admin,                 type: Mongoid::Boolean
    field :active,                type: Mongoid::Boolean
    field :first_name, type: String
    field :last_name,  type: String
    field :mobile,     type: String
    field :country_code, type: String, default: '995'

    # roles
    has_and_belongs_to_many :roles, class_name: 'Sys::Role'

    # customer registrations
    has_many :registrations, class_name: 'Customer::Registration'

    index({ email: 1 }, { unique: true })
    index(first_name: 1, last_name: 1)

    validates :email, uniqueness: { message: I18n.t('models.sys_user.errors.email_is_taken') }
    validates :email, email: { message: I18n.t('models.sys_user.errors.illegal_email') }
    validates :password, confirmation: { message: I18n.t('models.sys_user.errors.password_not_match') }
    validates :first_name, presence: { message: I18n.t('models.sys_user.errors.empty_first_name') }
    validates :last_name, presence: { message: I18n.t('models.sys_user.errors.empty_last_name') }
    validates :mobile, mobile: { message: I18n.t('models.sys_user.errors.illegal_mobile') }
    validate  :password_definition

    before_create :user_before_create
    before_save :user_before_save

    def full_name; "#{first_name} #{last_name}" end
    def self.encrypt_password(password, salt); Digest::SHA1.hexdigest("#{password}dimitri#{salt}") end
    def self.generate_hash(user); Digest::MD5.hexdigest("#{Time.now}#{rand(20111111)/11.0}#{user.email}") end
    def self.generate_sms_code; rand(99999).to_s.rjust(5,'0') end
    def to_s; full_name end
    def formatted_mobile
      if self.country_code == '995' then "(+995)#{KA::format_mobile(self.mobile)}"
      else "(+#{self.country_code})#{self.mobile}" end
    end

    def includes_role?(role); self.role_ids.include?(Moped::BSON::ObjectId.from_string(role)) end
    def admin?; self.admin end
    def tender_admin?; true end #self.admin? || self.includes_role?(Telasi::PERMISSIONS[:tender_admin_id]) || self.includes_role?(Telasi::PERMISSIONS[:tender_report_id]) end
    def cancelaria_user?; self.includes_role?(Telasi::PERMISSIONS[:network_cancelaria_id]) end

    attr_accessor :password_confirmation
    attr_reader :password

    def password=(pwd)
      @password = pwd
      return if pwd.blank?
      self.salt = "#{self.object_id}#{rand 1000}"
      self.hashed_password = User.encrypt_password(self.password, self.salt)
      self.password_restore_hash = nil
    end

    # Authenticate user (even inactive) using given email and password.
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

    def confirm_sms!(confirm_code)
      if self.email_confirmed
        true
      elsif Time.now > ( self.sms_code_expires_at || Date.new(1900, 1, 1) )
        false
      elsif self.sms_confirm_code == confirm_code
        self.email_confirmed = true
        self.sms_confirm_code = nil
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

    def subscription; Sys::Subscription.where(email: self.email).first end

    def send_confirmation
      UserMailer.email_confirmation(self).deliver if self.email_confirm_hash 
      send_sms_confirmation
    end

    def seconds_left_for_resend
      if Time.now < ( self.sms_next_resend_at || Date.new(1900, 1, 1) )
        return (self.sms_next_resend_at.to_i - Time.now.to_i) || 0
      else 
        return 0
      end
    end

    def send_sms_confirmation
      # return if self.email_confirmed
      return if seconds_left_for_resend > 0

      self.sms_confirm_code = User.generate_sms_code
      self.sms_code_expires_at = Time.now + EXPIRATION_MINUTES.minutes
      self.sms_next_resend_at = Time.now + NEXT_RESEND_IN_MINUTES.minutes
      self.save
      
      if Magti::SEND
        msg = "Telasi code: " + self.sms_confirm_code + "\n\n" + Telasi::SMS_SIGNATURE
        begin 
         Magti.send_sms(self.mobile, msg)
        rescue 
         self.destroy
         return
        end

        # #bacho 
        smsg = Sys::SentMessage.new
        smsg.company='MAGTI'
        smsg.receiver_mobile = '995' + self.mobile.to_s
        smsg.text = msg
        smsg.status='S'
        smsg.sent_at=Time.now
        smsg.sender_user='MyTelasiGe Registration'
        smsg.save
      end
    end

    private

    def password_definition
      if hashed_password.blank?
        errors.add(:password, I18n.t('models.sys_user.errors.empty_password'))
      end
    end

    def user_before_create
      if User.count == 0
        self.admin = true
        self.email_confirmed = true
        self.email_confirm_hash = nil
      else
        confirmed = false # (not Telasi::CONFIRM_ON_REGISTER)
        self.admin = false
        self.email_confirmed = confirmed
        self.email_confirm_hash = confirmed ? nil : User.generate_hash(self)
      end
      self.active = true
      self.email=self.email.downcase if self.email
    end

    def user_before_save; self.mobile = compact_mobile(self.mobile) end

  end
end
