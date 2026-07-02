#!/bin/sh
set -eu

BACKEND_URL="${BACKEND_URL:-http://localhost:8080}"
export BACKEND_URL

envsubst '${BACKEND_URL}' \
  < /usr/share/nginx/html/config.template.js \
  > /usr/share/nginx/html/config.js

exec nginx -g 'daemon off;'
