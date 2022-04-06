class User::PasswordsController < Devise::PasswordsController
  def update

    super do |resource|
      # Jump to super code
      next unless resource.errors.any?
      token_errors = resource.errors.details[:reset_password_token]
      expired_error = token_errors.select { |detail| detail[:error] == :expired }
      # Jump to super code

      if token_errors.present?
        message = resource.errors.full_messages_for(:reset_password_token).join(',')
        return redirect_to edit_user_user_password_path(reset_password_token: params["user_user"]["reset_password_token"]), alert: message
      end
      next unless expired_error.present?
      message = resource.errors.full_messages_for(:reset_password_token).join(',')
      return redirect_to edit_user_user_password_path(reset_password_token: params["user_user"]["reset_password_token"]), alert: message
    end
  end
end
