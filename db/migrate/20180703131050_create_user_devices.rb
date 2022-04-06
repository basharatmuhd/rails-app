class CreateUserDevices < ActiveRecord::Migration[5.2]
  def change
    create_table :user_devices do |t|
      t.references :user, foreign_key: true
      t.string :device_uid
      t.integer :last_sign_in_at

      t.timestamps
    end
    add_index :user_devices, [:device_uid, :user_id], unique: true
  end
end
