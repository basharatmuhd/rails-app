class Milestone < ApplicationRecord
  enum status: [:initial, :completed, :uncompleted]

  belongs_to :project

  validates :phase_name, presence: true
  validates :phase_name, uniqueness: { case_sensitive: false, scope: [:project_id] }

  has_many :images, as: :imageable, dependent: :destroy

  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: :all_blank

  before_validation :set_defaults, :if => :new_record?

  def can_update?
    !completed?
  end

  private

  def set_defaults
    self.status = :initial
  end
end
