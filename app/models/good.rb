class Good < ActiveRecord::Base

  ############# CONFIGURATION #############

  ## SETUP ASSOCIATIONS
  belongs_to :product
  belongs_to :selling_unit
  belongs_to :buyer, class_name: "User", foreign_key: :buyer_id
  belongs_to :producer, class_name: "User", foreign_key: :producer_id
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

  has_many :price_points


  ## ATTRIBUTE PROTECTION  
  
  attr_accessible :product_id, :price_point_ids, :selling_unit_id, :quantity,
    :indefinite, :start_date, :end_date


  ## ATTRIBUTE VALIDATION

  validates :name, :category_id, presence: true

  validates_attachment :pic,
    :size => { :in => 0..2.megabytes }

  #########################################




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

  scope :available_demand_only, includes(:agreements).where("agreements.buyer_id = 0")
  scope :available_supply_only, includes(:agreements).where("agreements.producer_id = 0")
  scope :available_demand_and_mine_only, lambda {|b| includes(:agreements).where("agreements.buyer_id = 0 OR agreements.buyer_id = ?", b)}
  scope :available_supply_and_mine_only, lambda {|p| includes(:agreements).where("agreements.producer_id = 0 OR agreements.producer_id = ?", p)}

  scope :in_month, lambda{|m| {:conditions => ['end_date >= ? AND start_date <= ?', Date.new(Date.today.year, m.to_i, 1), Date.new(Date.today.year, m.to_i, 1).end_of_month]}}

  scope :by_category_name, lambda {|c| includes(:category).where("categories.name = ?", c)}
  scope :by_name, lambda { |n| where('UPPER(goods.name) LIKE UPPER(?)', '%'+n+'%')}
  scope :in_category, lambda { |c| includes(:category).where(category_id: Category.where(id: c).first.self_and_descendant_ids) }

  scope :by_producer, lambda { |p| includes(:agreements).where("agreements.producer_id = ?", p) }
  scope :by_buyer, lambda { |p| includes(:agreements).where("agreements.buyer_id = ?", p) }

  scope :by_standing_supply, includes(:agreements).where("agreements.start_date <= ? AND agreements.agreement_type = ? AND agreements.buyer_id IS NULL", Date.today, "onetime")
  scope :by_standing_demand, includes(:agreements).where("agreements.start_date <= ? AND agreements.agreement_type = ? AND agreements.producer_id IS NULL", Date.today, "onetime")

  #########################################



  ############ CLASS METHODS ##############

  #def self.
  def self.csv_header 
    "ID,Category,Name,Description,Selling Unit,Catch Weight,Season Start Date,Season End Date".split(',') 
  end

  def self.build_from_csv(row)
    good = Good.where(id: row[0]).first_or_initialize
    start_date = row[6].split("-")
    end_date = row[7].split("-")
    good.attributes = {
      :unit_type => row[4],
      :catch_weight => row[5],
      :start_date => Date.new(start_date[2].to_i, start_date[0].to_i, start_date[1].to_i),
      :end_date => Date.new(end_date[2].to_i, end_date[0].to_i, end_date[1].to_i),
    }
    return good
  end


  ############ PUBLIC METHODS #############

  def to_csv
    [id, cat_name, name, description, unit_type, catch_weight, start_date, end_date]
  end

  def cat_name
    Category.where(id: category_id).first.name
  end

  def best_pic_url(sym)
    pic? ? pic.url(sym) : category.best_pic_url(sym)
  end

  def best_pic
    pic? ? pic : category.best_pic
  end

  def bar_margins
    "margin-left: " + bar_margin_left.to_s + "%; margin-right: " + bar_margin_right.to_s + "%;"
  end

  def start_bar_margins
    "margin-left: 0%; margin-right: " + bar_margin_right.to_s + "%;"
  end

  def end_bar_margins
    "margin-left: " + bar_margin_left.to_s + "%; margin-right: 0%;"
  end

  ############ PRIVATE METHODS ############
  private

  def bar_margin_left
    (start_date.yday.to_f/365)*100
  end

  def bar_margin_right
    100 - (end_date.yday.to_f/365)*100
  end

end
