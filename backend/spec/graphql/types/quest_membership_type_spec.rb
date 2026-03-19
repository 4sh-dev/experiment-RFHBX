# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::QuestMembershipType do
  subject(:type) { described_class }

  it "exposes the expected fields" do
    expected_fields = %w[id role character quest createdAt updatedAt]

    field_names = type.fields.keys
    expected_fields.each do |field|
      expect(field_names).to include(field), "Expected field '#{field}' to be defined on QuestMembershipType"
    end
  end

  it "marks role as nullable" do
    expect(type.fields["role"].type.non_null?).to be false
  end

  it "marks required fields as non-null" do
    %w[id character quest createdAt updatedAt].each do |field|
      expect(type.fields[field].type.non_null?).to be true
    end
  end

  it "resolves character as CharacterType" do
    expect(type.fields["character"].type.unwrap).to eq(Types::CharacterType)
  end

  it "resolves quest as QuestType" do
    expect(type.fields["quest"].type.unwrap).to eq(Types::QuestType)
  end
end
