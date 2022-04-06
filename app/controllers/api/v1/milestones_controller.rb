class Api::V1::MilestonesController < Api::ApiController
  before_action :load_milestone, only: [:update, :destroy, :mark_as_completed, :mark_as_uncompleted, :add_images]
  before_action :must_be_contractor, only: [:update, :destroy, :mark_as_completed, :mark_as_uncompleted, :add_images]

  def update
    if @milestone.can_update?
      @milestone.update!(milestone_params)
      project = @milestone.project
      ActivityService.create_activity('milestone.updated', current_user, project, @milestone, {phase_name: @milestone.phase_name})
      SystemMessageRelayJob.perform_now(project, 'milestone.updated', 'Milestone updated', recipient_ids: project.homeowner_ids + [project.user_id])
    end
    render json: @milestone
  end

  def destroy
    @milestone.destroy!
    if @milestone.destroyed?
      project = @milestone.project
      ActivityService.create_activity('milestone.destroyed', current_user, project, @milestone, {phase_name: @milestone.phase_name})
      SystemMessageRelayJob.perform_now(project, 'milestone.destroyed', 'Milestone was destroyed', recipient_ids: project.homeowner_ids + [project.user_id])
    end
    render json: {success: @milestone.destroyed?}
  end

  def mark_as_completed
    project = @milestone.project
    @milestone.completed!
    if @milestone.reload.completed?
      ActivityService.create_activity('milestone.completed', current_user, project, @milestone, {phase_name: @milestone.phase_name})
      NotificationsService.delay(priority: 3).notify(project.homeowners, 'Project Update: Phase Complete', 'Great News! Your contractor has completed a phase. See the latest updates to your project.')
      SystemMessageRelayJob.perform_now(project, 'milestone.completed', 'Milestone completed', recipient_ids: project.homeowner_ids + [project.user_id])

      process_after_milestone_completed(project)
    end
    render json: {completed: @milestone.completed?}
  end

  def mark_as_uncompleted
    @milestone.uncompleted!
    if @milestone.reload.uncompleted?
      project = @milestone.project
      unless project.active?
        project.active!
        SystemMessageRelayJob.perform_now(project, 'project.status.changed', 'active', recipient_ids: project.homeowner_ids + [project.user_id])
      end
      ActivityService.create_activity('milestone.uncompleted', current_user, @milestone.project, @milestone, {phase_name: @milestone.phase_name})
      NotificationsService.delay(priority: 3).notify(project.homeowners, 'Project Update: Phase Modified', 'Your contractor has made a change to a phase. See the latest updates to your project!')
      SystemMessageRelayJob.perform_now(project, 'milestone.uncompleted', 'Milestone uncompleted', recipient_ids: project.homeowner_ids + [project.user_id])
    end
    render json: {uncompleted: @milestone.uncompleted?}
  end

  def add_images
    old_image_urls = @milestone.images.pluck(:url)
    @milestone.update!(milestone_image_params)
    image_urls = @milestone.reload.images.pluck(:url)
    images_added = image_urls - old_image_urls
    images_removed = old_image_urls - image_urls
    project = @milestone.project
    ActivityService.create_activity('milestone.images-added-or-removed', current_user, project, @milestone, {phase_name: @milestone.phase_name, images_added: images_added, images_removed: images_removed})
    SystemMessageRelayJob.perform_now(project, 'milestone.images-added-or-removed', 'Milestone added images', recipient_ids: project.homeowner_ids + [project.user_id])
    render json: @milestone.reload.images
  end

  private

  def load_milestone
    @milestone = Milestone.find params[:id]
  end

  def load_project
    @project = current_user.projects.find params[:project_id]
  end

  def must_be_contractor
    unless current_user.contractor? && current_user.id == @milestone.project.user_id
      raise ApiError::Errors.new(code: 10401, message: I18n.t('only_contractor_could_do_action'))
    end
  end

  def process_after_milestone_completed(project)
    if project.all_completed? && project.paid?
      project.archived!
      SystemMessageRelayJob.perform_now(project, 'project.status.changed', 'archived', recipient_ids: project.homeowner_ids + [project.user_id]) if project.archived?
    elsif project.all_completed?
      project.completed!
      SystemMessageRelayJob.perform_now(project, 'project.status.changed', 'completed', recipient_ids: project.homeowner_ids + [project.user_id]) if project.completed?
    end
  end

  def milestone_params
    params.require(:milestone).permit(:phase_name, :phase_amount, :suggestions)
  end

  def milestone_image_params
    params.require(:milestone).permit(:phase_name, images_attributes: [:id, :url, :_destroy])
  end
end
