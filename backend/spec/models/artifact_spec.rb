# frozen_string_literal: true

require "rails_helper"

RSpec.describe Artifact, type: :model do
  subject(:artifact) { build(:artifact) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:artifact_type) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:character).optional }
  end

  describe "defaults" do
    subject(:artifact) { Artifact.new(name: "The One Ring", artifact_type: "ring") }

    it "defaults corrupted to false" do
      expect(artifact.corrupted).to be false
    end

    it "defaults stat_bonus to empty hash" do
      expect(artifact.stat_bonus).to eq({})
    end
  end

  describe "stat_bonus jsonb" do
    it "stores and retrieves jsonb data" do
      artifact = create(:artifact, stat_bonus: { "strength" => 10, "wisdom" => 5 })
      artifact.reload
      expect(artifact.stat_bonus).to eq({ "strength" => 10, "wisdom" => 5 })
    end
  end

  describe "factory" do
    it "creates a valid artifact" do
      expect(create(:artifact)).to be_persisted
    end

    it "creates a corrupted artifact with the corrupted trait" do
      artifact = create(:artifact, :corrupted)
      expect(artifact.corrupted).to be true
    end

    it "creates an artifact with an owner" do
      artifact = create(:artifact, :with_owner)
      expect(artifact.character).to be_present
    end
  end
end
