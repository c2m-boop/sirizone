require_relative 'lib/payment_service'

puts "Stripe POS - Terminal"
puts "---------------------"

if ENV['STRIPE_SECRET_KEY'].nil? || ENV['STRIPE_SECRET_KEY'].empty?
  puts "Error: STRIPE_SECRET_KEY not found in .env file."
  puts "Please copy .env.example to .env and set your Stripe API keys."
  exit
end

payment_service = PaymentService.new

puts "Enter amount to charge (in cents):"
amount = gets.chomp.to_i

if amount > 0
  payment_service.create_payment_intent(amount)
else
  puts "Invalid amount. Please enter a positive integer."
end
