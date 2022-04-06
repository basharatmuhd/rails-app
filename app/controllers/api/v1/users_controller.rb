class Api::V1::UsersController < Api::ApiController
  skip_before_action :authenticate_user, only: [:create]

  def create
    user = User.create!(user_params)
    if user.persisted?
      auth_token = KnockService.new_auth_token(user, params[:device_uid].presence)
      render json: user, meta: {jwt: auth_token.token, stripe_publishable_key: ENV['STRIPE_PUBLISHABLE_KEY']}, status: :created
    end
  end

  def update_profile
    @user = current_user
    old_email = @user.email
    @user.update!(user_params)
    auth_token = KnockService.new_auth_token(@user, params[:device_uid].presence)
    render json: @user, meta: {jwt: auth_token.token, stripe_publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'], is_stripe_customer: @user.stripe_customer?, can_receive_payments: @user.can_receive_payments?, can_deauthorize_merchant: @user.can_deauthorize_merchant? }
  end

  def update_push_token
    user_device = current_user.user_devices.find_by device_uid: params['device_uid']
    user_device.update!(push_token: params[:push_token]) if user_device
    render json: {success: user_device&.push_token?}
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :full_name, :role, :avatar_path)
  end

end
