# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestEvent, type: :model do
  subject(:quest_event) { build(:quest_event) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:quest) }
    it { is_expected.to validate_presence_of(:event_type) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:quest) }
  end

  describe "enum" do
    it "defines started event_type" do
      event = build(:quest_event, event_type: :started)
      expect(event).to be_started
    end

    it "defines progress event_type" do
      event = build(:quest_event, event_type: :progress)
      expect(event).to be_progress
    end

    it "defines completed event_type" do
      event = build(:quest_event, event_type: :completed)
      expect(event).to be_completed
    end

    it "defines failed event_type" do
      event = build(:quest_event, event_type: :failed)
      expect(event).to be_failed
    end

    it "defines restarted event_type" do
      event = build(:quest_event, event_type: :restarted)
      expect(event).to be_restarted
    end
  end

  describe "data jsonb" do
    it "stores and retrieves jsonb data" do
      event = create(:quest_event, data: { "progress" => 0.5, "notes" => "halfway there" })
      event.reload
      expect(event.data).to eq({ "progress" => 0.5, "notes" => "halfway there" })
    end
  end

  describe "factory" do
    it "creates a valid quest event" do
      expect(create(:quest_event)).to be_persisted
    end

    it "respects the event_type when specified" do
      event = create(:quest_event, event_type: :completed)
      expect(event.event_type).to eq("completed")
    end
  end
end
