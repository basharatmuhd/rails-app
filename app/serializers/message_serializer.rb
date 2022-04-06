class MessageSerializer < ActiveModel::Serializer
  attributes :id, :project_id, :content, :created_at
  belongs_to :user
end
