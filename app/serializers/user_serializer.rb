class UserSerializer < ActiveModel::Serializer
  attributes :id, :role, :email, :full_name, :avatar_path, :created_at
end
