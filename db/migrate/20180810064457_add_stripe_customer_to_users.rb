class AddStripeCustomerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_customer, :string
  end
end
