class Charge < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :stripe_charge, uniqueness: true
end
