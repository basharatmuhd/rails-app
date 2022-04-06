class ApiError::Errors < ApiError::Base
  def initialize(attrs, err_type=nil, object_type_title=nil)
    if attrs.present?
      attrs.each do |attr, value|
        instance_variable_set("@#{attr}".to_sym, value)
      end
    elsif err_type && object_type_title
      error_type = I18n.t "api_error.errors.#{err_type}"
      error_type.each do |attr, value|
        instance_variable_set("@#{attr}".to_sym, value)
      end
      msg = I18n.t("api_error.errors.#{err_type}.message", object_type_title: object_type_title)
      instance_variable_set('@message'.to_sym, msg)
    end
  end
end
