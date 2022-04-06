class Api::V1::MerchantsController < Api::ApiController
  before_action :must_be_contractor, only: [:authorize_url, :create, :stripe_account, :deauthorize]

  def stripe_account
    if @merchant = current_user.merchant
      begin
        account = Stripe::Account.retrieve(@merchant.stripe_user_id)
        render json: account, serializer: StripeAccountSerializer, root: :account and return
      rescue Exception => e
        raise ApiError::Errors.new(code: 10401, message: e.message)
      end
    end
    render json: {account: nil}
  end

  def authorize_url
    url = "https://connect.stripe.com/express/oauth/authorize?response_type=code&client_id=#{ENV['STRIPE_CLIENT_ID']}&state=#{Time.zone.now.to_f}&scope=read_only"
    render json: {url: url}
  end

  def create
    raise ApiError::Errors.new(code: 10501, message: I18n.t('you_had_connected')) if current_user.merchant
    options = {
              site: 'https://connect.stripe.com',
              authorize_url: '/oauth/authorize',
              token_url: '/oauth/token'
            }
    client = OAuth2::Client.new(ENV['STRIPE_CLIENT_ID'], ENV['STRIPE_SECRET_KEY'], options)
    resp = client.auth_code.get_token(params[:code]) rescue nil
    if resp
      attrs = { user: current_user, access_token: resp.token, refresh_token: resp.refresh_token, stripe_publishable_key: resp.params['stripe_publishable_key'], stripe_user_id: resp.params['stripe_user_id'] }
      if (merchant = Merchant.find_by(user_id: current_user.id)).nil?
        merchant = Merchant.create!(attrs)
      else
        merchant.update!(attrs)
      end
      account = Stripe::Account.retrieve resp.params['stripe_user_id']
      account.payout_schedule = {"interval":"manual"}
      account.save
    end
    render json: {stripe_publishable_key: merchant&.stripe_publishable_key}
  end

  def deauthorize
    if current_user.merchant.nil?
      raise ApiError::Errors.new(code: 10400, message: I18n.t('please_connect_stripe'))
    end
    unless current_user.can_deauthorize_merchant?
      raise ApiError::Errors.new(code: 10401, message: I18n.t('all_funds_need_to_be_paid_out'))
    end
    begin
      if (merchant = current_user.merchant)
        account = Stripe::Account.retrieve(merchant.stripe_user_id)
        account.deauthorize(ENV['STRIPE_CLIENT_ID'])
        merchant.destroy
        render json: {success: merchant.destroyed?} and return
      end
    rescue Exception => e
      raise ApiError::Errors.new(code: 10402, message: e.message)
    end
    render json: {success: false}
  end

  private

  def must_be_contractor
    raise ApiError::Errors.new(code: 10401, message: I18n.t('only_contractor_could_do_action')) unless current_user.contractor?
  end

end
