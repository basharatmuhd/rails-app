class CreateMilestones < ActiveRecord::Migration[5.2]
  def change
    create_table :milestones do |t|
      t.references :project, foreign_key: true
      t.string :phase_name
      t.float :phase_amount
      t.text :suggestions

      t.timestamps
    end
  end
end
