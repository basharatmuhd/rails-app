class ProjectWithProgressSerializer < ProjectSerializer
  attributes :completed, :deposit, :paid, :funded, :remaining_balance, :leveled_project_holding, :service_fee, :need_release_funds

  def completed
    # for showing 100%
    total = object.milestones.count
    total == 0 ? 0 : (100*(object.milestones.where(status: :completed).count/total.to_f)).round
  end

  def funded
    @deposit_for_homeowner = project_service.deposit(true)
    # for showing 100%
    (@deposit_for_homeowner*100.0 / object.total_amount_due).to_i
  end

  def deposit
    @deposit = project_service.deposit
  end

  def paid
    @paid = project_service.paid
  end

  def remaining_balance # Amount Due
    object.total_amount_due - @deposit_for_homeowner
  end

  def leveled_project_holding
    @deposit_for_homeowner - project_service.paid(true)
  end

  def service_fee
    project_service.service_fee
  end

  def need_release_funds
    !object.pending? && object.charges.where.not(stripe_charge: nil).where(stripe_payout: nil).where(immediate: false).exists?
  end

  private

  def project_service
    ProjectsService.new(object, current_user)
  end
end
