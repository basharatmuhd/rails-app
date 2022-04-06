class ApiErrorsSerializer < ActiveModel::Serializer
  attribute :errors

  def errors
    [{code: object.code, message: object.message}]
  end
end
