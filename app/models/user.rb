class User < ActiveRecord::Base
  ############# CONFIGURATION #############
  require 'geokit'
  include GeoKit::Geocoders


  ############# CONFIGURATION #############

  include Extensions::Authenticatable

  ## SETUP ASSOCIATIONS
  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true

  has_and_belongs_to_many :certifications

  has_many :delivery_windows, as: :deliverable, dependent: :destroy
  accepts_nested_attributes_for :delivery_windows, allow_destroy: true, reject_if: proc { |attrs| attrs['weekday'].blank? or attrs['start_hour'].blank? or attrs['start_hour'].blank? }

  has_attached_file :pic, styles: IMAGE_STYLES, default_url: :set_default_url_on_role

  has_many :agreements, foreign_key: :creator_id, dependent: :destroy


  ## ATTRIBUTE PROTECTION
  attr_accessible :first_name, :last_name, :email, :notes,
    :attachments_attributes, :role, :name, :phone, :growing_methods,
    :street_address_1, :street_address_2, :city, :state, :country, :zip,
    :description, :website, :twitter, :facebook, 
    :certification_ids, :text_updates, :complete,
    :has_eggs, :has_dairy, :has_livestock, :has_pantry, :pic, :custom_growing_methods,
    :transport_by, :delivery_windows_attributes, :size


  ## ATTRIBUTE VALIDATION
  validates :first_name, :last_name, :email,  presence: true
  validates :email,                           uniqueness: true
  validates :role,                            inclusion: {:in => ROLES.map{ |r| r.first}}

  validates :name, :phone, :description,
    :street_address_1, :city, :state, :zip,
    presence: true,
    :if => lambda { self.complete == true }

  validates :growing_methods, :size,
    presence: true,
    :if => lambda { self.role == "producer" and self.complete == true }

  validates_attachment :pic,
    :size => { :in => 0..2.megabytes }

  #########################################




  ################ CALLBACKS ################

  before_save :strip_whitespace, :set_lat_long
  
  #########################################


  ################ SCOPES #################

  scope :by_size, lambda {|s| where("size = ?", s)}
  scope :by_growing_methods, lambda {|g| where("growing_methods = ?", g)}
  scope :order_best_available, order("size ASC")

  scope :by_producer, where(role: "producer")
  scope :by_buyer, where(role: "buyer")
  scope :by_other, lambda {|u| u.producer? ? where(role: "buyer") : where(role: "producer")}

  scope :near, lambda{ |*args|
    origin = *args.first[:origin]
    origin_lat, origin_lng = origin
    origin_lat, origin_lng = (origin_lat.to_f / 180.0 * Math::PI), (origin_lng.to_f / 180.0 * Math::PI)
    within = *args.first[:within]
    {
      :conditions => %(
        (ACOS(COS(#{origin_lat})*COS(#{origin_lng})*COS(RADIANS(users.lat))*COS(RADIANS(users.lng))+
        COS(#{origin_lat})*SIN(#{origin_lng})*COS(RADIANS(users.lat))*SIN(RADIANS(users.lng))+
        SIN(#{origin_lat})*SIN(RADIANS(users.lat)))*3963) <= #{within[0]}
      ),
      :select => %( users.*,
        (ACOS(COS(#{origin_lat})*COS(#{origin_lng})*COS(RADIANS(users.lat))*COS(RADIANS(users.lng))+
        COS(#{origin_lat})*SIN(#{origin_lng})*COS(RADIANS(users.lat))*SIN(RADIANS(users.lng))+
        SIN(#{origin_lat})*SIN(RADIANS(users.lat)))*3963) AS distance
      )
    }
  }

  #########################################


  ############ CLASS METHODS ##############

  def self.csv_header
    "First Name,Last Name,Email".split(',')
  end

  def self.build_from_csv(row) 
    # find existing customer from email or create new 
    user = find_or_initialize_by_email(row[2]) 
    user.attributes = {
      :first_name => row[0],
      :last_name => row[1],
      :email => row[2]
    }
    return user
  end 


  ############ PUBLIC METHODS #############

  def to_csv
    [first_name, last_name, email]
  end


  def admin?
    role == "admin"
  end
  def buyer?
    role == "buyer"
  end
  def foodhub?
    role == "foodhub"
  end
  def producer?
    role == "producer"
  end

  def role_label
    ROLES[role]
  end

  def full_name
    first_name.capitalize + " " + last_name.capitalize
  end
  
  def formal_name
    last_name.capitalize + ", " + first_name.capitalize
  end

  def distance_from(otherlatlong)
    puts street_address_1
    puts otherlatlong
    a = Geokit::LatLng.new(latlong)
    b = Geokit::LatLng.new(otherlatlong)
    return '%.2f' % a.distance_to(b)
  end


  ## PRODUCER METHODS
  def display_size
    return "S" if size == 0
    return "M" if size == 1
    return "L" if size == 2
    return ""
  end


  ############ PRIVATE METHODS ############
  private

  def set_default_url_on_role
    "/assets/#{role}_profile_pics/:style/missing.png"
  end
  
  def strip_whitespace
    self.first_name = self.first_name.strip
    self.last_name = self.last_name.strip
    self.email = self.email.strip
    self.name = self.name.strip if self.name
  end

  def set_lat_long
    if complete
      res = MultiGeocoder.geocode(self.street_address_1 + (self.street_address_2 ? " " + self.street_address_2 : "") + ", " + self.city + ", " + self.state + " " + self.zip)
      self.latlong = res.ll
      self.lat = res.lat
      self.lng = res.lng
    end
  end

end
