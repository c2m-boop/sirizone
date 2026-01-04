import os
from flask import Flask, render_template, jsonify, request, send_from_directory
import stripe
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__, static_folder='public', static_url_path='')

stripe.api_key = os.getenv('STRIPE_SECRET_KEY')

@app.route('/')
def home():
    is_test_mode = stripe.api_key.startswith('sk_test')
    return render_template('terminal.html', is_test_mode=is_test_mode)

@app.route('/online-checkout')
def online_checkout():
    # Pass environment variable for the checkout page
    return render_template('checkout.html', STRIPE_PUBLISHABLE_KEY=os.getenv('STRIPE_PUBLISHABLE_KEY'))

@app.route('/connection_token', methods=['POST'])
def connection_token():
    try:
        token = stripe.terminal.ConnectionToken.create()
        return jsonify({'secret': token.secret})
    except Exception as e:
        return jsonify({'error': {'message': str(e)}}), 500

@app.route('/create-payment-intent', methods=['POST'])
def create_payment_intent():
    try:
        data = request.get_json()
        # Default to 1000 cents if not provided
        amount = data.get('amount', 1000)
        
        intent = stripe.PaymentIntent.create(
            amount=amount,
            currency='usd',
            payment_method_types=['card_present'],
            capture_method='manual',
        )
        return jsonify({'clientSecret': intent.client_secret})
    except Exception as e:
        return jsonify({'error': {'message': str(e)}}), 500

@app.route('/connection-check')
def connection_check():
    try:
        account = stripe.Account.retrieve()
        return jsonify({'status': 'connected', 'account_id': account.id})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 500

# Serve static files explicitly if needed (though static_folder handles it)
@app.route('/<path:path>')
def send_static(path):
    return send_from_directory('public', path)

if __name__ == '__main__':
    print("Starting Local Python Server...")
    print("Open http://localhost:4242 in your browser")
    app.run(port=4242)
