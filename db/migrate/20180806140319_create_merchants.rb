class CreateMerchants < ActiveRecord::Migration[5.2]
  def change
    create_table :merchants do |t|
      t.references :user, foreign_key: true
      t.string :access_token
      t.string :refresh_token
      t.string :stripe_publishable_key
      t.string :stripe_user_id

      t.timestamps
    end
  end
end
