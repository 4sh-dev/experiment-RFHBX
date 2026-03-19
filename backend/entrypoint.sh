#!/bin/bash
set -e

# Remove stale Puma PID file (left behind on ungraceful shutdown)
rm -f /app/tmp/pids/server.pid

# Ensure bin/ scripts are executable (bind-mount may lose execute bit)
chmod +x /app/bin/*

# Prepare database (create if needed, run migrations)
bundle exec rails db:prepare

exec "$@"
