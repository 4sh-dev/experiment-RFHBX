# frozen_string_literal: true

require "rails_helper"

RSpec.describe TestJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    it "logs the message and completes without error" do
      expect(Rails.logger).to receive(:info).with("[TestJob] performed with message: ping")
      described_class.new.perform("ping")
    end

    it "uses a default message when called without arguments" do
      expect(Rails.logger).to receive(:info).with("[TestJob] performed with message: ping")
      described_class.new.perform
    end

    it "logs a custom message" do
      expect(Rails.logger).to receive(:info).with("[TestJob] performed with message: smoke test")
      described_class.new.perform("smoke test")
    end
  end

  describe "enqueuing" do
    it "enqueues the job via perform_later" do
      expect { described_class.perform_later("hello") }.to have_enqueued_job(described_class)
    end

    it "enqueues with the correct argument" do
      expect { described_class.perform_later("hello") }
        .to have_enqueued_job(described_class).with("hello")
    end

    it "enqueues on the default queue" do
      expect { described_class.perform_later("hello") }
        .to have_enqueued_job(described_class).on_queue("default")
    end

    it "executes successfully when performed now" do
      allow(Rails.logger).to receive(:info)
      perform_enqueued_jobs { described_class.perform_later("drain test") }
      expect(Rails.logger).to have_received(:info)
        .with("[TestJob] performed with message: drain test")
    end
  end
end
