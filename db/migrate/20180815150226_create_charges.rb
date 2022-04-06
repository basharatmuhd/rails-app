class CreateCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :charges do |t|
      t.references :user, foreign_key: true
      t.references :project, foreign_key: true
      t.float :amount # in cents
      t.float :amount_for_merchant # in cents
      t.string :stripe_charge
      t.string :stripe_payout
      t.datetime :payout_created_at

      t.timestamps
    end
  end
end
