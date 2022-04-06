class MessageUsersService

  def self.record(message)
    project = message.project
    sender = message.user
    users = project.homeowners.to_a + [project.user]
    users -= [sender]
    users.each do |u|
      MessageUser.create(message: message, user: u)
    end
  end

end
