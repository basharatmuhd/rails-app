class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :client_name
      t.string :address
      t.string :duration
      t.float :total_amount_due
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
