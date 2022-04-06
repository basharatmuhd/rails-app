Stripe.api_key = ENV['STRIPE_SECRET_KEY']
StripeEvent.signing_secrets = [ ENV['STRIPE_SIGNING_SECRET'], ENV['STRIPE_SIGNING_SECRET_OF_CONNECT_APP'] ]

Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :api_key      => ENV['STRIPE_SECRET_KEY']
}

# webhook's url: http://www.samplehost.com/stripe_hook

StripeEvent.subscribe 'charge.succeeded' do |event|
  EventsService.record_stripe_event(event)
end

StripeEvent.subscribe 'charge.failed' do |event|
  EventsService.record_stripe_event(event)
end

StripeEvent.subscribe 'payout.paid' do |event|
  EventsService.record_stripe_event(event)
end

StripeEvent.subscribe 'payout.failed' do |event|
  EventsService.record_stripe_event(event)
end
