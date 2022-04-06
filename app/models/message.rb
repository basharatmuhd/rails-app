class Message < ApplicationRecord
  belongs_to :project
  belongs_to :user

  has_many :message_users, dependent: :delete_all

  after_create :broadcast_nessage

  private

  def broadcast_nessage
    MessageUser.create(message: self, user: user, unread: false)
    MessageRelayJob.perform_now(self, MessageSerializer.new(self).to_json)
  end
end
