class AddTimeColsToCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :charges, :charge_succeeded_at, :datetime
    add_column :charges, :payout_paid_at, :datetime
  end
end
