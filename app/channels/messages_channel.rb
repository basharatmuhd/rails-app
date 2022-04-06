class MessagesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "messages_channel:project-#{params[:project_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
