class Api::V1::ProjectsController < Api::ApiController
  before_action :must_be_contractor, only: [:create, :update, :destroy, :recap]
  before_action :load_project, only: [:show, :update, :destroy]
  before_action :check_new_homeowners, only: [:create, :update]

  def index
    if current_user.homeowner?
      @projects = Project.where(id: ProjectHomeowner.where(user_id: current_user.id).select(:project_id))
    else
      @projects = current_user.projects
    end
    @projects = @projects.where(status: :archived) if params[:archived].to_bool
    @projects = @projects.page(params[:page]).per(params[:per_page])
    message_users = current_user.message_users.joins(:message)
    render json: {
      projects: @projects.includes(:homeowners).map{|proj|
        { project: ProjectSerializer.new(proj),
          message_unread_count: message_users.where(messages: {project_id: proj.id}).where(unread: true).count,
          homeowners: proj.homeowners.map{|o| UserSerializer.new(o)}
        }
      }
    }
  end

  def create
    @project = current_user.projects.create!(project_params)
    ActivityService.create_activity('project.created', current_user, @project, @project)
    SystemMessageRelayJob.perform_now(@project, 'project.created', 'Project created', recipient_ids: @project.homeowner_ids + [@project.user_id])
    render json: {
      project: ProjectWithProgressSerializer.new(@project, scope: current_user, scope_name: 'current_user'),
      homeowners: @project.homeowners.map{|o| UserSerializer.new(o)},
      milestones: @project.milestones.includes(:images).map{|o| MilestoneWithImagesSerializer.new(o)}
    }
  end

  def update
    milestone_ids = @project.milestone_ids
    @project.update!(project_params)
    milestone_ids_added = @project.reload.milestone_ids - milestone_ids
    if milestone_ids_added.any?
      milestone_names_added = Milestone.where(id: milestone_ids_added).pluck(:phase_name)
      ActivityService.create_activity('project.milestones-added', current_user, @project, @project, {milestone_names_added: milestone_names_added})
      # SystemMessageRelayJob.perform_now(@project, 'project.milestones-added', 'Milestones added', recipient_ids: @project.homeowner_ids + [@project.user_id])
    end
    SystemMessageRelayJob.perform_now(@project, 'project.updated', 'Project updated', recipient_ids: @project.homeowner_ids + [@project.user_id])

    render json: {
      project: ProjectWithProgressSerializer.new(@project, scope: current_user, scope_name: 'current_user'),
      homeowners: @project.homeowners.map{|o| UserSerializer.new(o)},
      milestones: @project.milestones.includes(:images).map{|o| MilestoneWithImagesSerializer.new(o)}
    }
  end

  def show
    if current_user.homeowner?
      @charges = @project.charges.where.not(charge_succeeded_at: nil)
      deposit  = @charges.sum(:amount_for_merchant)/100.0
      paid     = @project.charges.where.not(payout_paid_at: nil).sum(:amount_for_merchant)/100.0
      acct_balance = deposit - paid  # Total amount pre-funded by homeowner - Paid
    end
    render json: {
      acct_balance: acct_balance,
      project: ProjectWithProgressSerializer.new(@project, scope: current_user, scope_name: 'current_user'),
      homeowners: @project.homeowners.map{|o| UserSerializer.new(o)},
      milestones: @project.milestones.includes(:images).map{|o| MilestoneWithImagesSerializer.new(o)}
    }
  end

  def destroy
    @project.archived! unless @project.made_charge?
    if @project.destroyed?
      ActivityService.create_activity('project.destroyed', current_user, @project, @project, {name: @project.name})
      SystemMessageRelayJob.perform_now(@project, 'project.destroyed', 'Project was destroyed', recipient_ids: @project.homeowner_ids + [@project.user_id])
    end
    render json: {success: @project.destroyed?}
  end

  def recap
    total = current_user.projects.count
    render json: { paid_amount: 0, unpaid_amount: 0,
      paid_percent: 0, unpaid_percent: 0, money_per_month: [] } and return if total == 0
    projects = current_user.projects
    total_amount = projects.sum(:total_amount_due)
    paid_projects = Charge.where(project: projects).where.not(payout_paid_at: nil).select(:project_id)
    paid_amount = projects.where(id: paid_projects).sum(:total_amount_due)
    unpaid_amount = total_amount - paid_amount

    report = Charge.where(project: projects).where.not(payout_paid_at: nil).select("to_char(payout_paid_at,'YYYY') as year, to_char(payout_paid_at,'MM') as month, sum(amount_for_merchant/100) as amount_for_merchant").order('year,month').group('year,month').last(5)
    current = Time.current
    dates = 3.downto(0).map{|i| current - i.months}
    money_per_month = dates.map do |d|
      data = report.select{|o| o.year.to_i == d.year && o.month.to_i == d.month}.first
      { year: d.year, month: d.month, amount_for_merchant: data&.amount_for_merchant || 0 }
    end
    render json: {
      paid_amount: paid_amount,
      unpaid_amount: unpaid_amount,
      paid_percent: 100.0*paid_amount / total_amount,
      unpaid_percent: 100.0*unpaid_amount / total_amount,
      money_per_month: money_per_month
    }
  end

  private

  def project_params
    params.require(:project).permit(:name, :client_name, :address, :duration,
    :total_amount_due, project_homeowners_attributes: [:id, :project_id, :email, :_destroy], milestones_attributes: [:id, :phase_name, :phase_amount, :suggestions, :_destroy])
  end

  def load_project
    if current_user.homeowner?
      projects = Project.where(id: ProjectHomeowner.where(user_id: current_user.id).select(:project_id))
    else
      projects = current_user.projects
    end
    @project = projects.find params[:id]
  end

  def must_be_contractor
    unless current_user.contractor?
      raise ApiError::Errors.new(code: 10401, message: I18n.t('only_contractor_could_do_action'))
    end
  end

  def check_new_homeowners
    emails = project_params[:project_homeowners_attributes]&.map{|o| o[:email]}&.compact&.uniq
    return true if emails.nil?

    contractors = User.contractor.where('LOWER(email) IN (?)', emails.map(&:downcase))
    if contractors.count > 0
      contractor_emails = contractors.pluck(:email)
      contractor_emails.each do |email|
        UserMailer.invite_signup_homeowner(email).deliver_later
      end
      response = {error: {code:10409, message: I18n.t('homeowner_must_signup_with_different_email'), invalid_homeowner_emails: contractor_emails}}
      render json: response and return
    end
  end
end
