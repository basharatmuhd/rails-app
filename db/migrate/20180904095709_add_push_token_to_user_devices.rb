class AddPushTokenToUserDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :user_devices, :push_token, :string
  end
end
