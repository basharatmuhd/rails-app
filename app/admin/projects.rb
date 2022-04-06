ActiveAdmin.register Project do
  actions :index, :show

  controller do
    def scoped_collection
      end_of_association_chain.includes(:user)
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :client_name
    column :duration
    column :total_amount_due
    column :user
    column :status

    actions
  end

  filter :name
  filter :client_name
  filter :status, as: :select, collection: Project.statuses

  show do
    attributes_table do
      row :name
      row :client_name
      row :address
      row :duration
      row :total_amount_due
      row :user
      row :status
      row :created_at
      row :updated_at
    end
  end

end
