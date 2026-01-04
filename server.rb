require 'sinatra'
require 'sinatra/reloader' if development?
require 'dotenv/load'
require 'stripe'

# Set your secret key. Remember to switch to your live secret key in production.
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :static, true
set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')

get '/' do
  erb :checkout
end

post '/create-payment-intent' do
  content_type :json
  
  begin
    data = JSON.parse(request.body.read)
    
    # Create a PaymentIntent with the order amount and currency
    payment_intent = Stripe::PaymentIntent.create(
      amount: 1000, # Amount in cents (e.g. $10.00)
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true,
      },
    )
    
    {
      clientSecret: payment_intent.client_secret,
    }.to_json
  rescue Stripe::StripeError => e
    status 500
    {
      error: {
        message: e.message,
      }
    }.to_json
  rescue => e
    status 500
    {
      error: {
        message: e.message,
      }
    }.to_json
  end
end
