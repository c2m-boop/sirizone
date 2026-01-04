FROM ruby:3.2.2-slim

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

COPY Gemfile ./

RUN bundle install

COPY . .

CMD ["bundle", "exec", "puma", "-p", "10000", "-e", "production"]
