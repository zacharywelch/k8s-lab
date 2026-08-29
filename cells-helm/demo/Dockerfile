FROM ruby:3.3-alpine
RUN apk add --no-cache build-base libpq-dev
WORKDIR /app
COPY Gemfile ./
RUN bundle install
COPY app.rb config.ru ./
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-p", "3000", "-b", "tcp://0.0.0.0"]
