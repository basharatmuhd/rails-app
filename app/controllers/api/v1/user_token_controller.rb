class Api::V1::UserTokenController < Knock::AuthTokenController
  include BaseErrorRescuable
  skip_before_action :verify_authenticity_token, raise: false

  def create
    raise ApiError::AccountNotActivated.new unless @entity.active?
    @authtoken = KnockService.new_auth_token(@entity, params[:device_uid].presence)
    render json: @entity,  meta: { jwt: @authtoken.token, stripe_publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'], is_stripe_customer: @entity.stripe_customer?, can_receive_payments: @entity.can_receive_payments?, can_deauthorize_merchant: @entity.can_deauthorize_merchant? }
  end
end
