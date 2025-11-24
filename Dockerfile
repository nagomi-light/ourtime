FROM ruby:3.4

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY ./src/Gemfile ./src/Gemfile.lock ./
RUN bundle install

COPY ./src /app

# wait-for-it を追加して DB が立ち上がるまで待機
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

