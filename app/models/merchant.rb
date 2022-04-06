class Merchant < ApplicationRecord
  belongs_to :user

  validates :user_id, :stripe_user_id, uniqueness: true
end
