class StripeAccountSerializer < ActiveModel::Serializer
  attributes :id, :business_name, :email, :country, :external_accounts

  def id
    object.id
  end

  def business_name
    object.business_name
  end

  def country
    object.country
  end

  def email
    object.email
  end

  def external_accounts
    object.external_accounts.data.map{|o|
      o.as_json(except: [:id, :account, :fingerprint, :tokenization_method, :name, :metadata])
    }
  end

  def country
    object.country
  end

  def country
    object.country
  end
end
