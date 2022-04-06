class RemovePhaseAmountFromMilestones < ActiveRecord::Migration[5.2]
  def change
    remove_column :milestones, :phase_amount, :float
  end
end
