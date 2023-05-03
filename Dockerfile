FROM php:8-apache

RUN apt-get update && apt-get install -y \
  --no-install-recommends \
  supervisor \
  cron \
  openssh-server \
  unixodbc-dev \
  gnupg \
  unzip

RUN docker-php-ext-install pdo_mysql && \
  a2enmod rewrite

RUN pecl install sqlsrv && \
  pecl install pdo_sqlsrv && \
  docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
  curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
  apt update && \
  ACCEPT_EULA=Y apt install -y --no-install-recommends \
  msodbcsql17 \
  mssql-tools

COPY ./laravel /var/www/html

RUN chown -R www-data:www-data /var/www/html && \
  echo "root:Docker!" | chpasswd  && \
  mkdir -p -m0755 /var/run/sshd

RUN cd /var/www/html && \
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
  php composer-setup.php && \
  php -r "unlink('composer-setup.php');" && \
  cp composer.phar /tmp

RUN /tmp/composer.phar create-project laravel/laravel:10.1.1 /tmp/laravel

COPY rootfs /

RUN chmod +x /etc/cron.d/laravel-queue && \
  chmod +x /etc/cron.d/laravel-queue && \
  touch /var/log/cron.log && \
  crontab /etc/cron.d/laravel-queue && \
  touch /var/log/cron.log

WORKDIR /var/www/html

EXPOSE 2222

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


