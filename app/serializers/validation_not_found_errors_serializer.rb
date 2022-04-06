class ValidationNotFoundErrorsSerializer < ActiveModel::Serializer
  attribute :errors

  def errors
    [{code: I18n.t("api_error.codes.not_found"), message: object.message, resource: object.model}]
  end
end
