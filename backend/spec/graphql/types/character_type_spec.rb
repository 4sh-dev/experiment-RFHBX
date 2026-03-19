# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::CharacterType do
  subject(:type) { described_class }

  it "exposes the expected fields" do
    expected_fields = %w[
      id name race realm title ringBearer
      level xp strength wisdom endurance
      status createdAt updatedAt
    ]

    field_names = type.fields.keys
    expected_fields.each do |field|
      expect(field_names).to include(field), "Expected field '#{field}' to be defined on CharacterType"
    end
  end

  it "marks nullable fields correctly" do
    expect(type.fields["realm"].type.non_null?).to be false
    expect(type.fields["title"].type.non_null?).to be false
  end

  it "marks required fields as non-null" do
    %w[id name race ringBearer level xp strength wisdom endurance status createdAt updatedAt].each do |field|
      expect(type.fields[field].type.non_null?).to be true
    end
  end
end
