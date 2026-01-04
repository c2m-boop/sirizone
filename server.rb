require 'sinatra'
require 'sinatra/reloader' if development?
require 'dotenv/load'
require 'stripe'

# Set your secret key. Remember to switch to your live secret key in production.
Stripe.api_key = ENV['STRIPE_SECRET_KEY']

set :static, true
set :public_folder, File.join(File.dirname(__FILE__), 'public')
set :views, File.join(File.dirname(__FILE__), 'views')
set :bind, '0.0.0.0' # Bind to all interfaces for Docker/Render
set :port, ENV.fetch('PORT', 4567)

get '/' do
  @is_test_mode = Stripe.api_key.to_s.start_with?('sk_test')
  erb :terminal
end

get '/online-checkout' do
  erb :checkout
end

get '/connection-check' do
  content_type :json
  begin
    # Retrieve account details to verify the key works
    account = Stripe::Account.retrieve
    { status: 'connected', account_id: account.id }.to_json
  rescue => e
    status 500
    { status: 'error', message: e.message }.to_json
  end
end

post '/connection_token' do
  content_type :json
  begin
    token = Stripe::Terminal::ConnectionToken.create
    { secret: token.secret }.to_json
  rescue => e
    status 500
    { error: { message: e.message } }.to_json
  end
end

post '/create-payment-intent' do
  content_type :json
  begin
    data = JSON.parse(request.body.read)
    amount = data['amount']
    
    intent = Stripe::PaymentIntent.create({
      amount: amount,
      currency: ENV['CURRENCY'] || 'usd',
      payment_method_types: ['card_present'],
      capture_method: 'manual',
    })
    
    { clientSecret: intent.client_secret }.to_json
  rescue => e
    status 500
    { error: { message: e.message } }.to_json
  end
end

post '/register_reader' do
  content_type :json
  begin
    data = JSON.parse(request.body.read)
    code = data['code']
    label = data['label'] || 'New Reader'
    
    if code.nil? || code.empty?
      status 400
      return { error: { message: 'Registration code is required' } }.to_json
    end

    reader = Stripe::Terminal::Reader.create({
      registration_code: code,
      label: label,
      location: ENV['LOCATION_ID'] # Optional
    })
    
    { reader: reader }.to_json
  rescue => e
    status 500
    { error: { message: e.message } }.to_json
  end
end
