class MessageRelayJob < ApplicationJob
  queue_as :message_job

  def perform(message, body)
    ActionCable.server.broadcast "messages_channel:project-#{message.project_id}",
      message_id: message.id,
      body: body
    MessageUsersService.delay(queue: "message_users-#{message.id}", priority: 0).record(message)
    NotificationsService.delay(queue: "notifications-#{message.id}", priority: 3, run_at: 30.seconds.from_now).notify_message(message)
  end

end
