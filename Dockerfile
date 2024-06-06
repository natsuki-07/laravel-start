# App RUnner用にx86_64アーキテクチャ向けのLinux環境を指定
FROM --platform=linux/x86_64 public.ecr.aws/docker/library/php:8.2-apache

# アプリケーションのディレクトリパス
ENV APP_DIR /app
# タイムゾーンを Asia/Tokyo (日本の標準時) に設定
ENV TZ Asia/Tokyo
# Composerがスーパーユーザーとして実行されることを許可
ENV COMPOSER_ALLOW_SUPERUSER 1
# Apacheサーバーのドキュメントルート
ENV APACHE_DOCUMENT_ROOT ${APP_DIR}/public

WORKDIR ${APP_DIR}

# aptパッケージマネージャを使用してパッケージリストを更新
# zipとunzipパッケージをインストール
# PHPの拡張機能である opcache, pcntl, sockets をインストール
# PECLを使用してRedis拡張機能をインストールし有効化
RUN apt-get update \
    && apt-get install -y --no-install-recommends zip unzip libpq-dev \
    && docker-php-ext-install -j$(nproc) opcache pdo_pgsql \
    && pecl install redis \
    && docker-php-ext-enable redis


# Webサーバー(apache)の設定

# public.ecr.aws/docker/library/composer:2からイメージを取得しDockerイメージ内の/usr/bin/composerにコピー
COPY --from=public.ecr.aws/docker/library/composer:2 /usr/bin/composer /usr/bin/composer
# composer.で始まるすべてのファイルを、${APP_DIR}にコピー
COPY composer.* ${APP_DIR}/
COPY apache2/sites-available/laravel.conf /etc/apache2/sites-available/laravel.conf

RUN a2ensite laravel \
    && a2enmod rewrite headers \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && sed -ri -e 's/^([ \t]*)(<\/VirtualHost>)/\1\tHeader set Access-Control-Allow-Origin "*"\n\1\tHeader set Access-Control-Allow-Methods "GET,HEAD,OPTIONS,POST,PUT,PATCH,DELETE"\n\1\tHeader set Access-Control-Allow-Headers "Access-Control-Allow-Headers, Origin, Accept, Authorization, X-Requested-With, Content-Type, Access-Control-Request-Method"\n\1\2/g' /etc/apache2/sites-available/*.conf \
    && composer install --no-dev --no-autoloader --no-scripts --no-progress

# Composerを使用して、プロダクション用に依存関係をインストール
RUN composer install --no-dev --no-autoloader --no-scripts --no-progress

# ホストマシンの全てのファイルをコンテナの ${APP_DIR} にコピー
COPY . ${APP_DIR}/

# コンテナ内の ${APP_DIR}/storage ディレクトリに対して、再帰的に権限を変更して、読み取り/書き込み/実行権限を付与
RUN chmod -Rv 0777 ${APP_DIR}/storage \
    && composer install --no-dev --no-progress --classmap-authoritative

ENV LOG_CHANNEL=stderr
