#!/usr/bin/env bash
set -o errexit

bundle install
RAILS_ENV=production bundle exec rails assets:precompile --force
RAILS_ENV=production bundle exec rails tailwindcss:build
RAILS_ENV=production bundle exec rails db:prepare
