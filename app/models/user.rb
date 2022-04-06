class User < ApplicationRecord
  include TokenAuthenticatable
  enum role: [:homeowner, :contractor, :admin]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable, :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :contacts, dependent: :destroy
  has_many :user_devices, dependent: :destroy
  has_many :projects, dependent: :destroy
  has_many :project_homeowners, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :message_users, dependent: :delete_all
  has_many :events, dependent: :delete_all

  has_many :charges, dependent: :destroy

  has_one :merchant, dependent: :destroy

  before_validation :set_defaults, :if => :new_record?

  def active?
    !inactive
  end

  def activate!
    update(inactive: false, otp: nil)
  end

  def invalidate_authentication_token!(device_uid)
    user_device = user_devices.find_by device_uid: device_uid
    user_device.update_columns(last_sign_in_at: nil) if user_device
  end

  def joined_project_ids
    project_ids = ProjectHomeowner.where(user: self).pluck(:project_id)
    project_ids + projects.pluck(:id)
  end

  def can_receive_payments?
    merchant && Merchant.where(stripe_user_id: merchant.stripe_user_id).count == 1
  end

  def can_deauthorize_merchant?
    merchant && Charge.where(project_id: projects.select(:id)).where(payout_paid_at: nil).empty? && Merchant.where(stripe_user_id: merchant.stripe_user_id).count == 1
  end

  def can_delete_card?
    stripe_customer? && charges.where(charge_succeeded_at: nil).empty?
  end

  def as_json(_options = nil)
    super(
    {
      only: [:id, :role, :email, :full_name, :avatar_path, :created_at]
    })
  end

  private

  def set_defaults
    self.role ||= :homeowner
  end
end
