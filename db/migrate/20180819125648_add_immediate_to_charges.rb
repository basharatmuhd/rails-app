class AddImmediateToCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :charges, :immediate, :boolean, default: false
  end
end
