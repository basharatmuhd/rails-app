class ApiErrorSerializer < ActiveModel::Serializer
  attribute :error

  def error
    {code: object.code, message: object.message}
  end
end
