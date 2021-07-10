command="wp --path=$WORDPRESS_HOME --allow-root "

set -ex; \
    $command --info; \
    $command core install --skip-email --url="$WORDPRESS_URL" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN" --admin_email="$WORDPRESS_EMAIL" --admin_password="$WORDPRESS_INITPW"; \
    $command --path="$WORDPRESS_HOME" plugin install litespeed-cache --activate; \
    chmod 755 "$WORDPRESS_HOME"/wp-content/; \
    \
    chown -R "$WORDPRESS_USER":"$WORDPRESS_GROUP" "$WORDPRESS_HOME"

rm -rf /usr/local/bin/wp

exec "$@"
