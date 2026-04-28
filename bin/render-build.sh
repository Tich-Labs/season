#!/usr/bin/env bash
set -o errexit

export RAILS_ENV=production

bundle install
bundle exec rails tailwindcss:build
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:prepare

# Load solid adapter schemas explicitly.
# db:prepare only migrates the primary database when all databases share
# the same DATABASE_URL, so the solid_cache/queue/cable tables never get
# created otherwise — causing 500s on any request that touches Rails.cache.
echo "Loading solid_cache schema..."
bundle exec rails db:schema:load:cache || { echo "ERROR: solid_cache schema load failed"; exit 1; }
echo "Loading solid_queue schema..."
bundle exec rails db:schema:load:queue || { echo "ERROR: solid_queue schema load failed"; exit 1; }
echo "Loading solid_cable schema..."
bundle exec rails db:schema:load:cable || { echo "ERROR: solid_cable schema load failed"; exit 1; }
echo "Solid schemas loaded successfully."
