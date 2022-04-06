class Api::V1::ContactsController < Api::ApiController

  def create
    @contact = current_user.contacts.create!(contact_params)
    UserMailer.contact_us(@contact).deliver_later
    render json: {success: true}
  end

  private

  def contact_params
    params.require(:contact).permit(:subject, :message)
  end

end
