class AddPhaseAmountToMilestones < ActiveRecord::Migration[5.2]
  def change
    add_column :milestones, :phase_amount, :float, default: 0
  end
end
