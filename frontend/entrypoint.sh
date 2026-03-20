#!/bin/bash
set -e

# Install any packages added to package.json since the Docker image (or
# the persisted frontend_node_modules volume) was last built.
npm install

exec "$@"
