class StripeCustomerSourcesSerializer < ActiveModel::Serializer
  attributes :id, :default_source, :sources

  def id
    object.id
  end

  def default_source
    object.default_source
  end

  def sources
    object.sources.data.map{|o|
      {id: o.id, object: o.object, brand: o.brand, country: o.country, cvc_check: o.cvc_check, exp_month: o.exp_month, exp_year: o.exp_year, last4: o.last4}
    }
  end
end
