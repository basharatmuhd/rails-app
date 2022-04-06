class AddFeeRateToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :fee_rate, :float
  end
end
