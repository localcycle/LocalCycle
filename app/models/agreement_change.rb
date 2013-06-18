class AgreementChange < ActiveRecord::Base
  ############# CONFIGURATION #############

  ## SETUP ASSOCIATIONS

  belongs_to :agreement
  belongs_to :agreement_change
  belongs_to :user

  has_one :successor, class_name: "AgreementChange", foreign_key: "agreement_change_id"

  has_many :delivery_windows, as: :deliverable, dependent: :destroy
  accepts_nested_attributes_for :delivery_windows, allow_destroy: true, reject_if: proc { |attrs| attrs['weekday'].blank? or attrs['start_hour'].blank? or attrs['start_hour'].blank? }

  ## ATTRIBUTE PROTECTION
  
  attr_accessible :price, :quantity, :frequency, :status,
    :agreement_id, :agreement_change_id, :user_id, :reason, 
    :transport_instructions, :agree

  ## ATTRIBUTE VALIDATION

  #validates

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

  default_scope order('created_at ASC')

  scope :by_agreed, where(status: "agreed")
  scope :by_terminated, where(status: "terminated")
  scope :by_user, lambda {|id| where(user_id: id)}
  scope :by_not_user, lambda {|id| where("user_id != ?", id)}

  #########################################



  ############ CLASS METHODS ##############

  #def self.

  ############ PUBLIC METHODS #############

  def row_status
    if !successor
      return "success" if status == "agreed"
      return "warning" if status == "pending"
      return "error" if status == "terminated"
    end
  end

  def agreed?
    status == "agreed"
  end

  def pending?
    status == "pending"
  end

  def terminated?
    status == "terminated"
  end

  def terminate_chain
    self.update_column("status", "terminated")
    agreement_change.terminate_chain if agreement_change
  end

  ############ PRIVATE METHODS ############
  private

end
