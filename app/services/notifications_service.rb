class NotificationsService

  def self.notify(users, title, body)
    client = Exponent::Push::Client.new
    push_messages = []
    users.each do |user|
      user.user_devices.where.not(push_token: nil).each do |ud|
        push_messages << {
          title: title,
          to: ud.push_token,
          sound: 'default',
          body: body
        }
      end
    end
    client.publish push_messages if push_messages.any?
  end

  def self.notify_message(message)
    if Delayed::Job.where(queue: "message_users-#{message.id}").exists?
      raise 'There is invalid something'
    end
    client = Exponent::Push::Client.new
    push_messages = []
    message.message_users.unread.find_each do |mu|
      mu.user.user_devices.where.not(push_token: nil).each do |ud|
        push_messages << {
          title: 'New Message!',
          to: ud.push_token,
          sound: 'default',
          body: 'You have a new message. Reply here!'
        }
      end
    end
    client.publish push_messages if push_messages.any?
  end

end
