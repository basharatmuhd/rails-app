class AddServiceFeeChargedToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :service_fee_charged, :boolean, default: false
  end
end
