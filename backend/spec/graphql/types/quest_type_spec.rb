# frozen_string_literal: true

require "rails_helper"

RSpec.describe Types::QuestType do
  subject(:type) { described_class }

  it "exposes the expected fields" do
    expected_fields = %w[
      id title description status dangerLevel region
      progress successChance questType campaignOrder
      attempts createdAt updatedAt
    ]

    field_names = type.fields.keys
    expected_fields.each do |field|
      expect(field_names).to include(field), "Expected field '#{field}' to be defined on QuestType"
    end
  end

  it "marks nullable fields correctly" do
    %w[description region successChance campaignOrder].each do |field|
      expect(type.fields[field].type.non_null?).to be false
    end
  end

  it "marks required fields as non-null" do
    %w[id title status dangerLevel progress questType attempts createdAt updatedAt].each do |field|
      expect(type.fields[field].type.non_null?).to be true
    end
  end
end
