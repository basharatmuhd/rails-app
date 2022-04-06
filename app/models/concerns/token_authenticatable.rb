require 'bcrypt'
module TokenAuthenticatable
  extend ActiveSupport::Concern

  class_methods do
    def from_token_request request
      email = request.params[:auth] && request.params[:auth][:email]
      entity = self.find_by email: email
      entity
    end

    def from_token_payload payload
      entity = self.find payload['sub']
      if entity
        user_device = entity.user_devices.find_by device_uid: payload['device_uid']
        entity = nil if !user_device || user_device.last_sign_in_at != payload['last_sign_in_at']
      end
      entity
    end
  end

  def to_token_payload(device_uid = nil)
    { sub: id, device_uid: device_uid, last_sign_in_at: Time.now.utc.to_i }
  end

  def update_last_sign_in_at payload
    user_device = user_devices.find_or_create_by device_uid: payload[:device_uid]
    user_device.update_columns(last_sign_in_at: payload[:last_sign_in_at]) if user_device
  end

  def authenticate(unencrypted_password)
    BCrypt::Password.new(encrypted_password) == unencrypted_password && self
  end

end
