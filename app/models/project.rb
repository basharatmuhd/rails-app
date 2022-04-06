class Project < ApplicationRecord
  FEE = 0.05 # 5% of total_amount_due

  enum status: [:pending, :active, :completed, :archived]

  belongs_to :user

  has_many :project_homeowners, dependent: :destroy
  has_many :homeowners, through: :project_homeowners, source: :user
  has_many :milestones, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :charges, dependent: :destroy

  validates :name, :client_name, :address, presence: true
  # validates :name, uniqueness: { case_sensitive: false, scope: [:user_id] }
  validates :total_amount_due, numericality: { greater_than_or_equal_to: 15 }

  accepts_nested_attributes_for :milestones, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :project_homeowners, allow_destroy: true, reject_if: :all_blank

  before_validation :set_defaults, :if => :new_record?

  def all_completed?
    milestones.exists? && milestones.where.not(status: :completed).empty?
  end

  def made_charge?
    stripe_charge?
  end

  def paid?
    all_paid = charges.exists? && charges.where(payout_paid_at: nil).empty?
    if all_paid
      paid_charges = charges.where.not(payout_paid_at: nil)
      all_paid = false if paid_charges.sum(:amount)/100.0 < total_amount_due
    end
    all_paid
  end

  def can_receive_payments?
    user.can_receive_payments? && milestones.exists? && charges.where.not(stripe_charge: nil).empty?
  end

  def amount_for_merchant
    total_amount_due * (1 - (fee_rate || Project::FEE))
  end

  private

  def set_defaults
    self.status = :pending
  end
end
