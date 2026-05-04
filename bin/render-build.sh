#!/usr/bin/env bash
set -o errexit

export RAILS_ENV=production

bundle install
bundle exec rails tailwindcss:build
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:prepare

# Migrate solid adapter databases explicitly.
# db:prepare only migrates the primary database when all databases share
# the same DATABASE_URL, so the solid_cache/queue/cable tables never get
# created otherwise — causing 500s on any request that touches Rails.cache.
echo "Migrating solid_cache database..."
bundle exec rails db:migrate:cache || { echo "ERROR: solid_cache migration failed"; exit 1; }
echo "Migrating solid_queue database..."
bundle exec rails db:migrate:queue || { echo "ERROR: solid_queue migration failed"; exit 1; }
echo "Migrating solid_cable database..."
bundle exec rails db:migrate:cable || { echo "ERROR: solid_cable migration failed"; exit 1; }
echo "Solid adapter databases migrated successfully."
