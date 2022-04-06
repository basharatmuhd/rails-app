ActiveAdmin.register User do
  actions :all, except: [:new, :edit]

  controller do
    def scoped_collection
      end_of_association_chain.where.not(role: :admin)
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :full_name
    column :role
    column :avatar do |obj|
      image_tag(obj.avatar_path, class: 'img-thumb') if obj.avatar_path?
    end

    actions
  end

  filter :full_name
  filter :email

  show do
    attributes_table do
      row :full_name
      row :email
      row :role
      row :avatar do |obj|
        image_tag(obj.avatar_path, class: 'img-thumb') if obj.avatar_path?
      end
      row :created_at
      row :updated_at
    end
  end

end
