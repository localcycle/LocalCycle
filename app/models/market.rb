class Market < ActiveRecord::Base
  ############# CONFIGURATION #############
 
  ## SETUP ASSOCIATIONS

  has_and_belongs_to_many :market_managers, class_name: "User", foreign_key: :market_id, :conditions => proc { "role = 'market_manager'" }
  has_and_belongs_to_many :producers, class_name: "User", foreign_key: :market_id, :conditions => proc { "role = 'producer'" }
  has_and_belongs_to_many :buyers, class_name: "User", foreign_key: :market_id, :conditions => proc { "role = 'buyer'" }

  has_and_belongs_to_many :goods

  has_and_belongs_to_many :users
  
  has_many :delivery_windows, as: :deliverable, dependent: :destroy
  accepts_nested_attributes_for :delivery_windows, allow_destroy: true, reject_if: proc { |attrs| attrs['weekday'].blank? or attrs['start_hour'].blank? or attrs['start_hour'].blank? }

  belongs_to :network
  
  has_attached_file :pic, styles: IMAGE_STYLES, default_url: "/assets/market_pics/:style/missing.png"

  ## ATTRIBUTE PROTECTION
  
  attr_accessible :name, :brief, :description, :pic, :phone,
    :billing_street_address_1, :billing_street_address_2, 
    :billing_city, :billing_state, :billing_country, :billing_zip,
    :website, :twitter, :facebook, :delivery_windows_attributes, :network_id, :day_of_week, :cycle, :start_time, :end_time

  ## ATTRIBUTE VALIDATION

  validates :name,
    :billing_street_address_1,
    :billing_city, :billing_state, :billing_country, :billing_zip,
    presence: true

  #########################################

  CYCLES = %w[daily weekly monthly yearly one-time]


  ############### CALLBACKS ###############

  #before_validation
  #after_validation
  #before_save
  #before_create
  #after_create
  #after_save
  #after_commit

  #########################################



  ################ SCOPES #################

  #scope :by_, where()
  #scope :by_, includes(:model).where()
  #scope :by_, lambda {|s| where()}

  #########################################



  ############ CLASS METHODS ##############

  #def self.

  ############ PUBLIC METHODS #############

  def address
    billing_street_address_1 + " " + billing_street_address_2 + " " + billing_city + ", " + billing_state + ", " + billing_zip
  end

  ############ PRIVATE METHODS ############
  private
end
