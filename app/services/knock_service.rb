class KnockService
  def self.new_auth_token(user, device_uid)
    auth_token = Knock::AuthToken.new payload: user.to_token_payload.merge(device_uid: device_uid)
    user.update_last_sign_in_at auth_token.payload
    auth_token
  end
end
