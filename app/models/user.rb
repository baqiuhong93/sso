# encoding: utf-8
class User < ActiveRecord::Base
  acts_as_easy_captcha
  
  has_many :authentications, :dependent => :delete_all
  has_many :access_grants, :dependent => :delete_all

  before_validation :initialize_fields, :on => :create

  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :timeoutable, :trackable, :validatable, :rememberable, :lockable, :authentication_keys => [:login]

  self.token_authentication_key = "oauth_token"

  attr_accessor :login
  
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :last_name, :login, :salt, :captcha
  
  validates_presence_of :name, :on => :create, :message => "用户名不能为空!"
  
  validates_length_of :name, :within => 6..15, :on => :create, :message => "用户名必须在6到15位之间!"
  
  validates_format_of :name, :with => /^[a-z0-9_]{6,15}$/, :on => :create, :message => "用户名不符合规则!"
  
  validates_uniqueness_of :name, :on => :create, :message => "用户名必须唯一!"
  
  validates_presence_of :email, :on => :create, :message => "Email不能为空!"
  
  validates_length_of :email, :within => 6..255, :on => :create, :message => "Email必须在6到255位之间!"
  
  validates_uniqueness_of :email, :on => :create, :message => "Email必须唯一!"
  
  validate :valid_captcha?, :on => :create

  def apply_omniauth(omniauth)
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def self.find_for_token_authentication(conditions)
    where(["access_grants.access_token = ? AND (access_grants.access_token_expires_at IS NULL OR access_grants.access_token_expires_at > ?)", conditions[token_authentication_key], Time.now]).joins(:access_grants).select("users.*").first
  end
  
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
  
  def initialize_fields
    self.status = "Active"
    self.expiration_date = 1.year.from_now
    self.salt = random_str(10)
  end
  
  def random_str(len)
    rand(36**(len-1)..36**(len)).to_s 36
  end
end
