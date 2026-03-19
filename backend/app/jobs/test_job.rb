# frozen_string_literal: true

# Smoke-test job used to verify that Sidekiq is wired up correctly.
# Enqueue via: TestJob.perform_later("hello")
# Or natively:  TestJob.new.perform("hello")
class TestJob < ApplicationJob
  queue_as :default

  def perform(message = "ping")
    Rails.logger.info("[TestJob] performed with message: #{message}")
  end
end
