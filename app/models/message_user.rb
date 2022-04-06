class MessageUser < ApplicationRecord
  belongs_to :message
  belongs_to :user

  validates :user_id, uniqueness: { scope: [:message_id] }

  scope :unread, -> { where(unread: true) }
end
