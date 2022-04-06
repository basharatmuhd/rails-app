class CreateProjectHomeowners < ActiveRecord::Migration[5.2]
  def change
    create_table :project_homeowners do |t|
      t.references :project, foreign_key: true
      t.string :email
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
