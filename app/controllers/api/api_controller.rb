class Api::ApiController < ActionController::API
  include Knock::Authenticable
  include BaseErrorRescuable

  undef_method :current_user # undef_method devise current_user for knock
  before_action :authenticate_user

  rescue_from ActiveRecord::RecordInvalid, with: :render_invalidation_error

  private

  def render_invalidation_error exception
    render json: exception.record, serializer: ValidationErrorsSerializer,
      adapter: :attributes, status: :unprocessable_entity
  end

end
