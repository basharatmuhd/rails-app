class Api::V1::ChargesController < Api::ApiController
  before_action :load_project
  before_action :check_current_user

  def index
    @charges = @project.charges.where.not(charge_succeeded_at: nil)
    project_service = ProjectsService.new(@project, current_user)
    paid     = project_service.paid
    amount_due = @project.total_amount_due - project_service.deposit(true)
    # acct_balance = if current_user.contractor?
    #   @project.total_amount_due - paid
    # elsif current_user.homeowner?
    #   deposit - paid  # Total amount pre-funded by homeowner - Paid
    # end

    render json: {
      total_amount_due: @project.total_amount_due,
      paid: paid,
      amount_due: amount_due, # remaining_balance
      acct_balance: 0,
      service_fee: project_service.service_fee,
      charges: @charges.includes(:project).map{|o| ChargeSerializer.new(o)}
    }
  end

  private

  def load_project
    @project = Project.find params[:project_id]
  end

  def check_current_user
    valid_user_ids = @project.homeowners.pluck(:id) << @project.user_id
    unless valid_user_ids.include?(current_user.id)
      raise ApiError::Errors.new(code: 10401, message: I18n.t('user_could_not_do_action'))
    end
  end

end
