class ApiError::Base < StandardError
  include ActiveModel::Serialization

  attr_reader :code, :message

  def initialize
    error_type = I18n.t self.class.name.underscore.gsub(%r{\/}, ".")
    error_type.each do |attr, value|
      instance_variable_set("@#{attr}".to_sym, value)
    end
  end

end
