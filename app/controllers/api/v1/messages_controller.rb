class Api::V1::MessagesController < Api::ApiController
  before_action :load_project, only: [:index]

  def create
    @message = current_user.messages.create!(message_params)
    render json: @message
  end

  def index
    valid_user_ids = @project.homeowners.pluck(:id) << @project.user_id
    @messages = valid_user_ids.include?(current_user.id) ? @project.messages : Message.none
    if @messages.exists?
      @message_users = current_user.message_users.joins(:message).where(messages: {project_id: @project.id})
      @message_users.update_all(unread: false)
    end
    @messages = @messages.order(created_at: :desc).page(params[:page]).per(params[:per_page])
    render json: @messages
  end

  def inbox
    @message_users = current_user.message_users
    rs = Message.where(id: @message_users.select(:message_id)).group(:project_id).select('MAX(id) AS max_id')
    @messages = Message.where(id: rs.map(&:max_id)).order(created_at: :desc)
    if current_user.contractor?
      projects = current_user.projects
    elsif current_user.homeowner?
      project_ids = ProjectHomeowner.where(user: current_user).select(:project_id)
      projects = Project.where(id: project_ids)
    end
    render json: {
      projects: projects.map{|o|
        users = [o.user] + o.homeowners
        msg = @messages.find_by project_id: o.id
        json_msg = MessageWithUnreadCountSerializer.new(msg, scope: current_user, scope_name: 'current_user') if msg
        {project: ProjectSerializer.new(o)}.merge(message: json_msg, users: users.map{|u| UserSerializer.new(u)})
      }
    }
  end

  def mark_all_as_read
    @message_users = current_user.message_users.joins(:message).where(messages: {project_id: params[:project_id]})
    if current_user.message_users.where(message_id: params[:message_id]).empty?
      MessageUser.create(message_id: params[:message_id], user: current_user, unread: false)
    end
    @message_users.update_all(unread: false)
    render json: {success: @message_users.where(unread: true).empty?}
  end

  private

  def message_params
    params.require(:message).permit(:project_id, :content)
  end

  def load_project
    @project = Project.find params[:project_id]
  end

end
