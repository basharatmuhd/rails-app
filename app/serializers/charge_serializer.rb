class ChargeSerializer < ActiveModel::Serializer
  attributes :id, :project_id, :user_id, :immediate, :source_brand, :total_project, :amount, :amount_for_merchant, :charge_succeeded_at, :payout_paid_at

  def total_project
    object.project.total_amount_due
  end

  def amount
    object.amount/100.0
  end

  def amount_for_merchant
    object.amount_for_merchant/100.0
  end

end
