FROM ruby:3.4

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs curl && \
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

# wait-for-it を追加して DB が立ち上がるまで待機
USER root
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod 755 /usr/local/bin/wait-for-it

# appuserに戻す
USER appuser

# サーバー起動
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]