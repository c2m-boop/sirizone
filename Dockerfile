FROM ruby:3.2

WORKDIR /app

# Copy Gemfile
COPY Gemfile ./

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Start command
CMD ["sh", "-c", "bundle exec puma -p ${PORT:-10000} -e production"]
