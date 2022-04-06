class AddStripeFeeToCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :charges, :stripe_fee, :float
    add_column :charges, :net_amount, :float, default: 0
  end
end
