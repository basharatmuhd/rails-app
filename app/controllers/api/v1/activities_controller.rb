class Api::V1::ActivitiesController < Api::ApiController
  before_action :load_project
  before_action :check_current_user

  def index
    @activities = PublicActivity::Activity.where(recipient: @project).order(id: :desc)

    render json: @activities.includes(:owner, :trackable), each_serializer: ActivitySerializer, root: 'activities'
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
