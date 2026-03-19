# frozen_string_literal: true

require "sidekiq/testing"

# Use fake mode by default so workers are never executed in the test suite
# and no Redis connection is required. Jobs are pushed to an in-memory queue
# which can be inspected and drained in specs.
#
# Usage in specs:
#
#   # Check that a job was enqueued
#   expect { TestJob.perform_later }.to change(TestJob.jobs, :size).by(1)
#
#   # Drain the queue and verify side effects
#   TestJob.drain
#
#   # Use inline mode for a specific example when you want the job to run
#   # synchronously:
#   around do |example|
#     Sidekiq::Testing.inline! { example.run }
#   end
Sidekiq::Testing.fake!

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
