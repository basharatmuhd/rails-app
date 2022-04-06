class MessageWithUnreadCountSerializer < MessageSerializer
  attributes :unread_count

  def unread_count
    current_user.message_users.joins(:message).where(messages: {project_id: object.project_id, user_id: object.user_id}).where(unread: true).count
  end
end
