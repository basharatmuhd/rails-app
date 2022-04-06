class AddSourceBrandToCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :charges, :source_brand, :string
  end
end
