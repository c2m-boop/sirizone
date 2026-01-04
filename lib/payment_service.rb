require 'stripe'
require 'dotenv/load'

class PaymentService
  def initialize
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  end

  def create_payment_intent(amount, currency = 'usd')
    begin
      payment_intent = Stripe::PaymentIntent.create(
        amount: amount,
        currency: currency,
        payment_method_types: ['card'],
      )
      puts "Payment Intent created successfully: #{payment_intent.id}"
      puts "Client Secret: #{payment_intent.client_secret}"
      payment_intent
    rescue Stripe::StripeError => e
      puts "Error creating Payment Intent: #{e.message}"
      nil
    end
  end
end
