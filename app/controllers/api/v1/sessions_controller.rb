class Api::V1::SessionsController < Api::ApiController
  skip_before_action :authenticate_user, except: [:sign_out]

  def sign_out
    current_user.invalidate_authentication_token!(params[:device_uid])
    render json: {success: true}
  end

end
