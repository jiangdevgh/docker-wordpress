FROM wordpress:php8.0-apache

ENV WORDPRESS_USER www-data
ENV WORDPRESS_GROUP www-data
ENV WORDPRESS_HOME /var/www/html

# install pecl extensions
RUN set -ex; \
        pecl install redis-5.3.4; \
        docker-php-ext-enable redis; \
        rm -r /tmp/pear

# config php
RUN set -eux; \
        { \
            echo 'upload_max_filesize=10m'; \
        } > /usr/local/etc/php/conf.d/custom.ini

# install wordpress cli
# https://make.wordpress.org/cli/2018/05/31/gpg-signature-change/
# pub   rsa2048 2018-05-31 [SC]
#       63AF 7AA1 5067 C056 16FD  DD88 A3A2 E8F2 26F0 BC06
# uid           [ unknown] WP-CLI Releases <releases@wp-cli.org>
# sub   rsa2048 2018-05-31 [E]
ENV WORDPRESS_CLI_GPG_KEY 63AF7AA15067C05616FDDD88A3A2E8F226F0BC06
ENV WORDPRESS_CLI_VERSION 2.5.0
ENV WORDPRESS_CLI_SHA512 08dd9035fda1d529807380d5b757839e2809e289eb1a698fe33e7e21a1431d3f77c551c2b2db5adc55083d5075ea4137407994111890f765e790a97e6d9ca7af

RUN set -ex; \
    \
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends gnupg ; \
	\
	curl -o /usr/local/bin/wp.gpg -fL "https://github.com/wp-cli/wp-cli/releases/download/v${WORDPRESS_CLI_VERSION}/wp-cli-${WORDPRESS_CLI_VERSION}.phar.gpg"; \
	\
	GNUPGHOME="$(mktemp -d)"; export GNUPGHOME; \
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$WORDPRESS_CLI_GPG_KEY"; \
	gpg --batch --decrypt --output /usr/local/bin/wp /usr/local/bin/wp.gpg; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /usr/local/bin/wp.gpg; unset GNUPGHOME; \
	\
	echo "$WORDPRESS_CLI_SHA512 */usr/local/bin/wp" | sha512sum -c -; \
	chmod +x /usr/local/bin/wp; \
	chown ${WORDPRESS_USER}:${WORDPRESS_GROUP} /usr/local/bin/wp; \
	wp --allow-root --version; \
	\
	apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# install other requirements
RUN set -ex; \
        apt-get update; \
        apt-get install -y --no-install-recommends sudo ; \
        rm -rf /var/lib/apt/lists/*

# install wordpress plugins through cli
ARG WORDPRESS_URL
ARG WORDPRESS_TITLE
ARG WORDPRESS_ADMIN
ARG WORDPRESS_EMAIL
ARG WORDPRESS_INITPW

ENV WORDPRESS_URL="$WORDPRESS_URL"
ENV WORDPRESS_TITLE="$WORDPRESS_TITLE"
ENV WORDPRESS_ADMIN="$WORDPRESS_ADMIN"
ENV WORDPRESS_EMAIL="$WORDPRESS_EMAIL"
ENV WORDPRESS_INITPW="$WORDPRESS_INITPW"

COPY ./initialize.sh /usr/local/bin/initialize.sh
RUN chmod +x /usr/local/bin/initialize.sh

# inject entrypoint
RUN sed -i '/exec "$@"/i initialize.sh' /usr/local/bin/docker-entrypoint.sh
