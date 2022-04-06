class MilestoneSerializer < ActiveModel::Serializer
  attributes :id, :project_id, :phase_name, :phase_amount, :suggestions, :status
end
