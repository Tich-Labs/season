# Defer job enqueuing until any surrounding Active Record transaction
# commits, so a job can never run against a row that a later rollback
# undoes. `config.active_job.enqueue_after_transaction_commit` does NOT
# apply this — Rails' own railtie deliberately excludes that key from the
# config it propagates — so it has to be set on the class directly.
#
# No job is currently enqueued inside a `transaction do...end` block or a
# model callback in this app, but this is the safe default for a Rails 8.1
# app going forward.
ActiveJob::Base.enqueue_after_transaction_commit = true
