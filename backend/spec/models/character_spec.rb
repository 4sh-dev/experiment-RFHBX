# frozen_string_literal: true

require "rails_helper"

RSpec.describe Character, type: :model do
  subject(:character) { build(:character) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:race) }
    it { is_expected.to validate_numericality_of(:level).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:xp).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:strength).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:wisdom).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:endurance).is_greater_than(0) }
  end

  describe "associations" do
    it { is_expected.to have_many(:quest_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:quests).through(:quest_memberships) }
    it { is_expected.to have_many(:artifacts).dependent(:nullify) }
  end

  describe "defaults" do
    subject(:character) { Character.new(name: "Frodo", race: "Hobbit") }

    it "defaults ring_bearer to false" do
      expect(character.ring_bearer).to be false
    end

    it "defaults level to 1" do
      expect(character.level).to eq(1)
    end

    it "defaults xp to 0" do
      expect(character.xp).to eq(0)
    end

    it "defaults strength to 5" do
      expect(character.strength).to eq(5)
    end

    it "defaults wisdom to 5" do
      expect(character.wisdom).to eq(5)
    end

    it "defaults endurance to 5" do
      expect(character.endurance).to eq(5)
    end

    it "defaults status to idle" do
      expect(character.status).to eq("idle")
    end
  end

  describe "enum" do
    it "defines idle status" do
      character = build(:character, status: :idle)
      expect(character).to be_idle
    end

    it "defines on_quest status" do
      character = build(:character, status: :on_quest)
      expect(character).to be_on_quest
    end

    it "defines fallen status" do
      character = build(:character, status: :fallen)
      expect(character).to be_fallen
    end
  end

  describe "factory" do
    it "creates a valid character" do
      expect(create(:character)).to be_persisted
    end

    it "creates a ring bearer with the ring_bearer trait" do
      character = create(:character, :ring_bearer)
      expect(character.ring_bearer).to be true
    end

    it "creates a fallen character with the fallen trait" do
      character = create(:character, :fallen)
      expect(character.status).to eq("fallen")
    end
  end
end
