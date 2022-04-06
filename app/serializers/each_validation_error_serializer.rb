class EachValidationErrorSerializer
  def initialize record, error_field, details, message
    @record = record
    @error_field = error_field
    @details = details
    @message = message
  end

  def generate
    customize_message
    {
      resource: resource,
      field: field,
      error: error,
      code: code,
      message: @message
    }
  end

  private

  def resource
    @record.class.name
  end

  def field
    @error_field
  end

  def error
    @details[:error]
  end

  def code
    I18n.t "api_validation.codes.#{@details[:error]}"
  end

  def customize_message
    if resource == 'Project' && field == :'project_homeowners.email' && error == :taken
      @message = I18n.t "project_homeowner_email_taken"
    end
  end
end
