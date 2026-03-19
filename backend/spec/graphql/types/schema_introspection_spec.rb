# frozen_string_literal: true

require "rails_helper"

# These specs verify that all five domain object types and six enum types
# are listed in `__schema { types }` via HTTP introspection after being
# registered with `extra_types`.
#
# Field-level verification is covered by the dedicated type spec files
# (character_type_spec.rb, quest_type_spec.rb, etc.) which inspect the
# GraphQL Ruby class directly.

RSpec.describe "GraphQL schema — registered types", type: :request do
  let(:all_type_names) do
    result = gql("{ __schema { types { name } } }")
    result.dig("data", "__schema", "types").map { |t| t["name"] }
  end

  # Object types
  it "lists Character (CharacterType) in the schema" do
    expect(all_type_names).to include("Character")
  end

  it "lists Quest (QuestType) in the schema" do
    expect(all_type_names).to include("Quest")
  end

  it "lists Artifact (ArtifactType) in the schema" do
    expect(all_type_names).to include("Artifact")
  end

  it "lists QuestMembership in the schema" do
    expect(all_type_names).to include("QuestMembership")
  end

  it "lists SimulationConfig in the schema" do
    expect(all_type_names).to include("SimulationConfig")
  end

  # Enum types
  it "lists CharacterStatusEnum" do
    expect(all_type_names).to include("CharacterStatusEnum")
  end

  it "lists RaceEnum" do
    expect(all_type_names).to include("RaceEnum")
  end

  it "lists QuestStatusEnum" do
    expect(all_type_names).to include("QuestStatusEnum")
  end

  it "lists QuestTypeEnum" do
    expect(all_type_names).to include("QuestTypeEnum")
  end

  it "lists RegionEnum" do
    expect(all_type_names).to include("RegionEnum")
  end

  it "lists SimulationModeEnum" do
    expect(all_type_names).to include("SimulationModeEnum")
  end
end
