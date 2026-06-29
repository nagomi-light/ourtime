FROM ruby:3.4

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y \
      build-essential \
      libpq-dev \
      nodejs \
      curl \
      git \
      chromium \
      chromium-driver \
      fonts-liberation \
      libnss3 \
      libatk-bridge2.0-0 \
      libgtk-3-0 \
      libx11-xcb1 \
      libxcomposite1 \
      libxdamage1 \
      libxrandr2 \
      libgbm1 \
      libasound2 \
      libpangocairo-1.0-0 \
      libxshmfence1 && \
    npm install -g yarn esbuild && \
    rm -rf /var/lib/apt/lists/*

# アプリユーザー作成
RUN useradd -m appuser

WORKDIR /app

# /app の権限変更
RUN chown appuser:appuser /app

# Gemfile をコピー
COPY ./src/Gemfile ./src/Gemfile.lock ./

# Gemfileの権限変更
RUN chown appuser:appuser Gemfile Gemfile.lock

# appuser に切り替えてbundle install
USER appuser
RUN bundle install

# ソースコードをコピー（rootではなくappuserでコピー）
COPY --chown=appuser:appuser ./src /app

# JS / CSS / Tailwind / FullCalendar ビルド
RUN yarn install --frozen-lockfile
RUN bundle exec rails assets:precompile

# wait-for-it を追加して DB が立ち上がるまで待機
USER root
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod 755 /usr/local/bin/wait-for-it

# appuserに戻す
USER appuser

# サーバー起動
CMD ["bash", "-c", "\
bundle exec rails db:prepare && \
bundle exec rails runner 'Rails.application.load_seed if User.count.zero?' && \
bundle exec rails server -b 0.0.0.0 -p 3000"]
