class Api::V1::PaymentsController < Api::ApiController
  before_action :must_be_homeowner, only: [:add_customer, :add_card, :charge, :customer_sources, :delete_card, :release_funds]
  before_action :load_project, only: [:charge, :release_funds]

  def add_customer
    if params[:stripe_token].present? && !current_user.stripe_customer?
      begin
        customer_id = payment_service.create_customer! params[:stripe_token]
        render json: {stripe_customer: customer_id} and return
      rescue Exception => e
        raise ApiError::Errors.new(code: 10401, message: e.message)
      end
    end
    raise ApiError::Errors.new(code: 10402, message: I18n.t('some_errors'))
  end

  def add_card
    if params[:stripe_token].present? && current_user.stripe_customer?
      begin
        card_id = payment_service.add_card! params[:stripe_token]
        render json: {card_id: card_id} and return
      rescue Exception => e
        raise ApiError::Errors.new(code: 10401, message: e.message)
      end
    end
    raise ApiError::Errors.new(code: 10402, message: I18n.t('some_errors'))
  end

  def delete_card
    unless current_user.can_delete_card?
      raise ApiError::Errors.new(code: 10400, message: I18n.t('should_not_delete_card'))
    end
    if params[:card_id].present? && current_user.stripe_customer?
      begin
        customer = Stripe::Customer.retrieve(current_user.stripe_customer)
        customer.sources.retrieve(params[:card_id]).delete
        render json: {success: true} and return
      rescue Exception => e
        raise ApiError::Errors.new(code: 10401, message: e.message)
      end
    end
    raise ApiError::Errors.new(code: 10402, message: I18n.t('some_errors'))
  end

  def customer_sources
    if current_user.stripe_customer?
      begin
        customer = Stripe::Customer.retrieve(current_user.stripe_customer)
        render json: customer, serializer: StripeCustomerSourcesSerializer, root: :customer and return
      rescue Exception => e
        raise ApiError::Errors.new(code: 10401, message: e.message)
      end
    end
    raise ApiError::Errors.new(code: 10402, message: I18n.t('some_errors'))
  end

  def release_funds
    raise ApiError::Errors.new(code: 10401, message: 'Cannot release funds when the project is pending') if @project.pending?
    begin
      @project.charges.where.not(stripe_charge: nil).where(stripe_payout: nil).each do |charge_record|
        PaymentsService.payout charge_record unless charge_record.immediate
      end
      render json: {success: true} and return
    rescue Exception => e
      raise ApiError::Errors.new(code: 10400, message: e.message)
    end
    render json: {success: false}
  end

  def charge
    amount = params[:amount].to_i
    raise ApiError::Errors.new(code: 10400, message: I18n.t('contractor_should_add_milestones')) if @project.milestones.empty?
    unless @project.user.merchant
      NotificationsService.delay(priority: 3).notify([@project.user], 'Payment', 'Please add your bank account to receive payment for your projects!')
      raise ApiError::Errors.new(code: 10403, message: I18n.t('contractor_not_added_bank_account'))
    end
    current = @project.total_amount_due*100 - @project.charges.sum(:amount)
    remainder = current - amount*100
    raise ApiError::Errors.new(code: 10405, message: I18n.t('remainder_should_greater_than_or_equal_to_15_dollar')) if remainder != 0 && remainder < 1500 # $15
    if current_user.stripe_customer? # && amount == @project.total_amount_due.to_i
      begin
        opts = {immediate: params[:immediate].to_bool, source_id: params[:source_id]}
        charge_id = payment_service.charge(amount, current_user.stripe_customer, @project, opts)
        @project.update_columns stripe_charge: charge_id, service_fee_charged: true if @project.stripe_charge.nil? && charge_id.present?
        render json: {stripe_charge: charge_id} and return
      rescue Exception => e
        raise ApiError::Errors.new(code: 10401, message: e.message)
      end
    end
    raise ApiError::Errors.new(code: 10402, message: I18n.t('some_errors'))
  end

  private

  def payment_service
    @service ||= PaymentsService.new(homeowner: current_user)
  end

  def must_be_homeowner
    raise ApiError::Errors.new(code: 10401, message: I18n.t('only_homeowner_could_do_action')) unless current_user.homeowner?
  end

  def load_project
    if current_user.homeowner?
      projects = Project.where(id: ProjectHomeowner.where(user_id: current_user.id).select(:project_id))
    else
      projects = current_user.projects
    end
    @project = projects.find params[:project_id]
    @project = nil if @project.homeowners.where(id: current_user.id).empty?
  end
end
