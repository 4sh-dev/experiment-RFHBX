# frozen_string_literal: true

module Types
  class QuestMembershipType < Types::BaseObject
    description "Represents a character's membership in a quest"

    field :id, ID, null: false
    field :role, String, null: true
    field :character, Types::CharacterType, null: false
    field :quest, Types::QuestType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
