#!/bin/bash
set -euo pipefail

#config php
phpini=/usr/local/lsws/lsphp80/etc/php/8.0/litespeed/php.ini
set -ex; \
    sed -i 's/upload_max_filesize.*/upload_max_filesize = 10M/' $phpini

WORDPRESS_HOME='/var/www/vhosts/localhost/html'
command="wp --path=$WORDPRESS_HOME --allow-root "

plugins=(litespeed-cache seo-by-rank-math tk-google-fonts wp-editormd 'https://git-updater.com/wp-content/uploads/2021/07/git-updater-10.4.1.zip;git-updater')
themes=('https://github.com/jiangdevgh/wp-2016-lite/archive/refs/heads/master.zip;wp-2016-lite')

config() {
    $command config create --force --dbhost="$WORDPRESS_DB_HOST" --dbname="$WORDPRESS_DB_NAME" --dbuser="$WORDPRESS_DB_USER" --prompt=dbpass < /run/secrets/mysql_password
}

install_site() {
    if ! $command core is-installed; then
        $command core download --path="$WORDPRESS_HOME" --skip-content --locale=zh_CN
        config
        $command core install --skip-email --url="$WORDPRESS_URL" --title="$WORDPRESS_TITLE" --admin_user="$WORDPRESS_ADMIN" --admin_email="$WORDPRESS_EMAIL" --admin_password="$WORDPRESS_INITPW"
    else
        config
    fi
}

install_plugins() {
    for plugin in "${plugins[@]}"; do
        url="${plugin%%;*}"
        name="${plugin##*;}"
        if ! $command plugin is-installed "$name"; then
            $command plugin install "$url"
        fi
        if ! $command plugin is-active "$name"; then
            $command plugin activate "$name"
        fi
    done
}

install_themes() {
    for theme in "${themes[@]}"; do
        url="${theme%%;*}"
        name="${theme##*;}"
        if ! $command theme is-installed "$name"; then
            $command theme install "$url"
        fi
        if ! $command theme is-active "$name"; then
            $command theme activate "$name"
        fi
    done
}

install_site
install_plugins
install_themes
chmod 755 "$WORDPRESS_HOME"/wp-content/
chown -R 1000:1000 "$WORDPRESS_HOME"

rm -rf /usr/local/bin/wp

exec "$@"
