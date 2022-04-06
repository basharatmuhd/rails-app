class Api::V1::PasswordsController < Api::ApiController
  skip_before_action :authenticate_user

  def create
    @user = User.find_by email: params[:email]
    render json: {error: {code: 10404, message: I18n.t('user_not_found')}}, status: 404 and return unless @user
    UserMailer.reset_password_instructions(@user).deliver_now
    render json: { user: {id: @user.id}, message: I18n.t('email_sent')}, status: 201
  end

  def update
    @user = User.reset_password_by_token reset_password_token: params[:reset_password_token], password: params[:password], password_confirmation: params[:password_confirmation]

    render json: {error: {code: 10504, message: I18n.t('change_password_failed')}}, status: 422  and return unless @user.id
    render json: {error: {code: 10505, message: @user.errors.full_messages.first}}, status: 422 and return if @user.errors.any?
    @user.invalidate_authentication_token!(params[:device_uid])
    render json: {user: @user, message: "Your Password has been successfully changed"}
  end

end
