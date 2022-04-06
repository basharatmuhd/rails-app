class AddStripeChargeToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :stripe_charge, :string
  end
end
