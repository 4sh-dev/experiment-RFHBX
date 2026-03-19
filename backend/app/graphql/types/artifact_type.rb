# frozen_string_literal: true

module Types
  class ArtifactType < Types::BaseObject
    description "A powerful artifact from the age of legends"

    field :id, ID, null: false
    field :name, String, null: false
    field :artifact_type, String, null: false
    field :power, String, null: true
    field :corrupted, Boolean, null: false
    field :stat_bonus, GraphQL::Types::JSON, null: false
    field :character, Types::CharacterType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
