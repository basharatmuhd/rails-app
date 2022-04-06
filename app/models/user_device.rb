class UserDevice < ApplicationRecord
  belongs_to :user

  validates :device_uid, uniqueness: { case_sensitive: false, scope: [:user_id] }
end
