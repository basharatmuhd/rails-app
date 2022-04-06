class Event < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :targetable, polymorphic: true, optional: true
  belongs_to :project, optional: true
end
