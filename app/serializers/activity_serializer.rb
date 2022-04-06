class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :key, :owner_id, :owner_type, :owner, :trackable_id, :trackable_type, :trackable, :parameters, :created_at

  def owner
    if object.owner.is_a?(User)
      UserSerializer.new(object.owner).attributes
    elsif object.owner.is_a?(Charge)
      ChargeSerializer.new(object.owner).attributes
    end
  end

  def trackable
    MilestoneSerializer.new(object.trackable).attributes if object.trackable.is_a?(Milestone)
  end
end
