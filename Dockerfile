FROM ruby:3.2-slim

# Install build dependencies
RUN apt-get update -qq && apt-get install -y build-essential

WORKDIR /app

# Copy Gemfile
COPY Gemfile ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Start command
CMD ["sh", "-c", "bundle exec puma -p ${PORT:-10000} -e production"]
