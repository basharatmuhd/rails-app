class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :client_name, :address, :duration, :total_amount_due, :status, :made_charge
  belongs_to :user

  def made_charge
    object.stripe_charge?
  end
end
