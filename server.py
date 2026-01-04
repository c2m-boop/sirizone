import os
import stripe
from flask import Flask, render_template, jsonify, request
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup Stripe
stripe.api_key = os.getenv('STRIPE_SECRET_KEY')

app = Flask(__name__, static_url_path='/static', static_folder='public', template_folder='templates')

@app.route('/')
def home():
    is_test_mode = "sk_test" in stripe.api_key
    return render_template('terminal.html', is_test_mode=is_test_mode, simulated=is_test_mode)

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
        amount = data.get('amount')
        
        intent = stripe.PaymentIntent.create(
            amount=amount,
            currency='usd',
            payment_method_types=['card_present'],
            capture_method='manual',
        )
        return jsonify({'clientSecret': intent.client_secret})
    except Exception as e:
        return jsonify({'error': {'message': str(e)}}), 500

@app.route('/register_reader', methods=['POST'])
def register_reader():
    try:
        data = request.get_json()
        code = data.get('code')
        label = data.get('label', 'New Reader')
        
        if not code:
            return jsonify({'error': {'message': 'Registration code is required'}}), 400

        reader = stripe.terminal.Reader.create(
            registration_code=code,
            label=label,
            location=os.getenv('LOCATION_ID') # Optional: use if you have locations
        )
        return jsonify({'reader': reader})
    except Exception as e:
        return jsonify({'error': {'message': str(e)}}), 500

if __name__ == '__main__':
    print(f"Server running on http://localhost:4242")
    app.run(port=4242, debug=True)
