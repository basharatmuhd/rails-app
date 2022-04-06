class PaymentsService

  def initialize(homeowner: )
    @user = homeowner
  end

  def create_customer!(stripe_token)
    return nil if @user.stripe_customer?
    customer_id = Stripe::Customer.create(
      email: @user.email,
      source: stripe_token,
      description: 'Customer on Hyperlect'
    ).id
    @user.update_columns(stripe_customer: customer_id)
    customer_id
  end

  def add_card!(stripe_token)
    customer = Stripe::Customer.retrieve(@user.stripe_customer)
    card_id = customer.sources.create(source: stripe_token).id
    customer.default_source = card_id
    customer.save
    card_id
  end

  def charge(amount, stripe_customer_id, project, opts = {})
    unless project.fee_rate?
      project.update fee_rate: Project::FEE
    end
    amount = (100 * amount).to_i
    amount_for_merchant = (amount - amount * project.fee_rate).to_i
    # stripe_fee = 0.029*amount + 30 # https://stripe.com/us/pricing
    unless amount > 0 && amount * project.fee_rate > 0.029*amount + 30
      raise I18n.t('amount_should_greater_than_or_equal_to_15_dollar')
    end
    merchant = project.user.merchant
    connected_stripe_account_id = merchant.stripe_user_id
    metadata = {project_id: project.id, merchant_id: merchant.id, contractor_email: merchant.user.email}
    args = {
      amount: amount, # Amount in cents
      currency: 'usd',
      customer: stripe_customer_id,
      description: "Hyperlect: charge for #{project.name}",
      receipt_email: merchant.user.email,
      destination: {
        amount: amount_for_merchant,
        account: connected_stripe_account_id,
      },
      metadata: metadata
    }
    args.merge!(source: opts[:source_id]) if opts[:source_id].present?
    charge_id = Stripe::Charge.create(args).id
    if charge_id
      charge_record = @user.charges.create(project: project, amount: amount, amount_for_merchant: amount_for_merchant, stripe_charge: charge_id)
    end
    if opts[:immediate] && charge_record&.persisted?
      charge_record.update(immediate: true)
    end
    charge_id
  end

  def self.payout(charge)
    merchant = charge.project.user.merchant
    connected_stripe_account_id = merchant.stripe_user_id
    metadata = {project_id: charge.project.id, merchant_id: merchant.id, contractor_email: merchant.user.email, charge_id: charge.id}
    unless charge.stripe_payout?
      payout_id = Stripe::Payout.create({
        amount: charge.amount_for_merchant.to_i,
        currency: 'usd',
        statement_descriptor: "Hyperlect: payout for #{charge.project.name}",
        metadata: metadata
      }, {
        stripe_account: connected_stripe_account_id
      }).id
      charge.update(stripe_payout: payout_id, payout_created_at: Time.now.utc) if payout_id
    end
  end
end
