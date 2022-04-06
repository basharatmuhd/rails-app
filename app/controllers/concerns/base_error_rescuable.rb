module BaseErrorRescuable
  extend ActiveSupport::Concern

  included do
    rescue_from ApiError::Base, with: :render_api_error
    rescue_from ApiError::Errors, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
  end

  private

  def render_api_error exception
    render json: exception, serializer: ApiErrorsSerializer,
      adapter: :attributes, status: :bad_request
  end

  def render_error exception
    render json: exception, serializer: ApiErrorsSerializer,
      adapter: :attributes, status: :bad_request
  end

  def render_not_found_error exception
    render json: exception, serializer: ValidationNotFoundErrorsSerializer,
      adapter: :attributes, status: :not_found
  end
end
