class ActivityService
  def self.create_activity(key, owner, recipient, trackable, parameters = {})
    PublicActivity::Activity.create(key: key, parameters: parameters,
      trackable: trackable, owner: owner, recipient: recipient)
  end

end
