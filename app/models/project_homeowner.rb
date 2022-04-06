class ProjectHomeowner < ApplicationRecord
  belongs_to :project
  belongs_to :user, optional: true

  validates :email, uniqueness: { scope: [:project_id] }
  validates :user_id, uniqueness: { scope: [:project_id] }, allow_nil: true

  after_create :set_user

  private

  def set_user
    self.user = User.homeowner.find_by(email: email)
    if user
      UserMailer.invite_homeowner(user).deliver_later
    else
      pwd = SecureRandom.hex(10)
      self.user = User.homeowner.create(email: email, full_name: email, password: pwd)
      UserMailer.invite_homeowner(user, pwd, true).deliver_later if user.persisted?
    end
    self.update user_id: user.id
  end
end
