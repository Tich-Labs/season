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
bundle exec rails db:cache:schema:load
bundle exec rails db:queue:schema:load
bundle exec rails db:cable:schema:load
