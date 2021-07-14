FROM litespeedtech/openlitespeed:1.7.12-lsphp80

# install other requirements
RUN set -ex; \
        apt-get update; \
        apt-get install -y --no-install-recommends sudo ; \
        rm -rf /var/lib/apt/lists/*

# install wordpress & plugins through cli
COPY initialize.sh /usr/local/bin/initialize.template
COPY .env /usr/local/bin/.env
RUN set -ex; \
        echo "$(cat /usr/local/bin/.env)\n$(cat /usr/local/bin/initialize.template)" > /usr/local/bin/initialize.sh; \
        cat /usr/local/bin/initialize.sh; \
        chmod +x /usr/local/bin/initialize.sh; \
        rm /usr/local/bin/initialize.template /usr/local/bin/.env

# inject entrypoint
RUN sed -i '1a set -euo pipefail\ninitialize.sh' /entrypoint.sh
