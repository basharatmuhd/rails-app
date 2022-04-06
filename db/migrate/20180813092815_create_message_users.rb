class CreateMessageUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :message_users do |t|
      t.references :message, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :unread, default: true

      t.timestamps
    end
    add_index :message_users, [:user_id, :message_id], unique: true
  end
end
