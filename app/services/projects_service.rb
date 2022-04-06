class ProjectsService

  def initialize(project, user)
    @user = user
    @project = project
  end

  def deposit(for_homeowner = false)
    charges = @project.charges.where.not(charge_succeeded_at: nil)
    if @user.homeowner? || for_homeowner
      return charges.sum(:amount)/100.0
    elsif @user.contractor?
      return charges.sum(:amount_for_merchant)/100.0
    end
    0
  end

  def paid(for_homeowner = false)
    charges = @project.charges.where.not(payout_paid_at: nil)
    if @user.homeowner? || for_homeowner
      return charges.sum(:amount)/100.0
    elsif @user.contractor?
      return charges.sum(:amount_for_merchant)/100.0
    end
    0
  end

  def service_fee
    charges = @project.charges.where.not(payout_paid_at: nil)
    return nil if charges.empty?
    if @user.homeowner?
      return 0
    elsif @user.contractor?
      return (@project.fee_rate || Project::FEE) * charges.sum(:amount)/100.0
    end
  end

end
