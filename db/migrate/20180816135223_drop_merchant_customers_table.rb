class DropMerchantCustomersTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :merchant_customers do |t|
      t.references :merchant, foreign_key: true
      t.references :user, foreign_key: true
      t.string :stripe_customer

      t.timestamps
    end
  end
end
