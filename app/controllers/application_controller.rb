class ApplicationController < ActionController::Base
  private

  def authenticate_active_admin_user!
     authenticate_user!
     unless current_user.admin?
        flash.now[:alert] = "You are not authorized to access this resource!"
        redirect_to root_path
     end
  end
end
