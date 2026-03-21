#!/bin/bash
set -e

# Remove stale Puma PID file (left behind on ungraceful shutdown)
rm -f /app/tmp/pids/server.pid

# Install any gems added to the Gemfile since the Docker image (or the
# persisted backend_bundle volume) was last built.  `bundle check` exits
# 0 when everything is satisfied, so `bundle install` only runs when
# there is actually something new to fetch.
bundle check || bundle install

# Prepare database (create if needed, run migrations)
bundle exec rails db:prepare

exec "$@"
