# Stripe POS

This project uses the Stripe Ruby gem.

## Prerequisites

- Ruby (tested with 3.x)
- Bundler

## Installation

1. Install Ruby.
2. Run `bundle install` to install the dependencies (including `stripe`).

## Stripe CLI

To install the Stripe CLI on Windows, run:

```bash
winget install Stripe.StripeCli
```

Note: You may need to restart your terminal after installation for the `stripe` command to be available.

## Usage

1. Copy `.env.example` to `.env` and add your Stripe API keys.
   ```bash
   cp .env.example .env
   ```
2. Run the application:
   ```bash
   ruby app.rb
   ```

3. Run the web server (Sinatra):
   ```bash
   ruby server.rb
   ```
   Then open http://localhost:4567 in your browser.

## Deploy to Render

1. Create a new Web Service on [Render](https://render.com).
2. Connect your repository.
3. Render will automatically detect the `render.yaml` file (Blueprints).
4. **Important**: In the Render Dashboard, go to your service's **Environment** tab and add the following environment variables:
   - `STRIPE_PUBLISHABLE_KEY`: Your live or test publishable key.
   - `STRIPE_SECRET_KEY`: Your live or test secret key.
   - `CURRENCY`: `usd` (default).

The service is configured to use `puma` as the web server for production performance.
