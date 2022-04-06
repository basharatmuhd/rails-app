class MilestoneWithImagesSerializer < MilestoneSerializer
  has_many :images, as: :imageable
end
