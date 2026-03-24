# frozen_string_literal: true

require "rails_helper"

# Verifies that config/sidekiq_cron.yml is well-formed and references real
# worker classes.  These assertions catch the class of regression where
# a worker is renamed or the cron file drifts out of sync with the code.
RSpec.describe "Sidekiq cron schedule", type: :job do
  let(:cron_file) { Rails.root.join("config/sidekiq_cron.yml") }

  let(:schedule) do
    rendered = ERB.new(File.read(cron_file)).result
    YAML.safe_load(rendered)
  end

  it "config/sidekiq_cron.yml exists" do
    expect(cron_file).to exist
  end

  it "parses as valid YAML and returns a non-empty Hash" do
    expect { schedule }.not_to raise_error
    expect(schedule).to be_a(Hash).and be_present
  end

  describe "quest_tick entry" do
    subject(:entry) { schedule["quest_tick"] }

    it { is_expected.to be_present }

    it "targets QuestTickWorker" do
      expect(entry["class"]).to eq("QuestTickWorker")
    end

    it "has a cron expression" do
      expect(entry["cron"]).to be_present
    end
  end

  describe "eye_of_sauron entry" do
    subject(:entry) { schedule["eye_of_sauron"] }

    it { is_expected.to be_present }

    it "targets EyeOfSauronWorker" do
      expect(entry["class"]).to eq("EyeOfSauronWorker")
    end

    it "has a cron expression" do
      expect(entry["cron"]).to be_present
    end
  end

  describe "all scheduled worker classes" do
    it "exist and include Sidekiq::Worker" do
      schedule.each_value do |entry|
        klass_name = entry["class"]
        klass = klass_name.constantize
        expect(klass.ancestors).to include(Sidekiq::Worker),
          "Expected #{klass_name} to include Sidekiq::Worker"
      end
    end

    it "all define a #perform instance method" do
      schedule.each_value do |entry|
        klass_name = entry["class"]
        klass = klass_name.constantize
        expect(klass.instance_methods).to include(:perform),
          "Expected #{klass_name} to define #perform"
      end
    end
  end
end
