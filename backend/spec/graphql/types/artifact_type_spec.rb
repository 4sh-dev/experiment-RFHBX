# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::ArtifactType do
  subject(:type) { described_class }

  it "exposes the expected fields" do
    expected_fields = %w[
      id name artifactType power corrupted
      statBonus character createdAt updatedAt
    ]

    field_names = type.fields.keys
    expected_fields.each do |field|
      expect(field_names).to include(field), "Expected field '#{field}' to be defined on ArtifactType"
    end
  end

  it "marks nullable fields correctly" do
    %w[power character].each do |field|
      expect(type.fields[field].type.non_null?).to be false
    end
  end

  it "marks required fields as non-null" do
    %w[id name artifactType corrupted statBonus createdAt updatedAt].each do |field|
      expect(type.fields[field].type.non_null?).to be true
    end
  end
end
