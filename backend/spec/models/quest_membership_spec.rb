# frozen_string_literal: true

require "rails_helper"

RSpec.describe QuestMembership, type: :model do
  subject(:membership) { build(:quest_membership) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:character) }
    it { is_expected.to validate_presence_of(:quest) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:character) }
    it { is_expected.to belong_to(:quest) }
  end

  describe "uniqueness" do
    it "allows the same character on multiple quests that are not active" do
      character = create(:character)
      quest1 = create(:quest, status: :pending)
      quest2 = create(:quest, status: :pending)
      create(:quest_membership, character: character, quest: quest1)
      membership2 = build(:quest_membership, character: character, quest: quest2)
      expect(membership2).to be_valid
    end

    it "does not allow duplicate membership on the same quest" do
      character = create(:character)
      quest = create(:quest)
      create(:quest_membership, character: character, quest: quest)
      duplicate = build(:quest_membership, character: character, quest: quest)
      expect(duplicate).not_to be_valid
    end
  end

  describe "factory" do
    it "creates a valid quest membership" do
      expect(create(:quest_membership)).to be_persisted
    end
  end
end
