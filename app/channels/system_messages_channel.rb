class SystemMessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "system_messages_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
