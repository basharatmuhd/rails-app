class SystemMessageRelayJob < ApplicationJob
  queue_as :system_message_job

  def perform(project, type, msg, opts)
    ActionCable.server.broadcast "system_messages_channel",
      project_id: project.id,
      body: msg,
      message_type: type,
      sender: 'system',
      recipient_ids: opts[:recipient_ids]
  end

end
