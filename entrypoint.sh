#!/bin/sh

set -x

set /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf -n "$@"

if [[ ! -v PUID ]]; then
  PUID="$(id -u www-data)"
fi
if [[ ! -v PGID ]]; then
  PGID="$(id -g www-data)"
fi

if [ -z "$(ls -A /var/www/html)" ]; then
   cp -a /tmp/laravel/. /var/www/html/
fi

rm -r /tmp/laravel

if [[ ! -v DEV ]]; then
  /usr/bin/php /var/www/html/artisan route:cache && \
  /usr/bin/php /var/www/html/composer.phar install --optimize-autoloader
fi

groupmod -g $PGID www-data && \
usermod -u $PUID -g $PGID www-data && \

chown -R www-data:www-data /var/www/html

# replace the current pid 1 with original entrypoint
exec "$@"
