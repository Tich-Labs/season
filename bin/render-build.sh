#!/usr/bin/env bash
set -o errexit

export RAILS_ENV=production

bundle install
bundle exec rails tailwindcss:build
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:prepare
