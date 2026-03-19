# frozen_string_literal: true

module Types
  class CharacterType < Types::BaseObject
    description "A Middle-earth character who can join quests"

    field :id, ID, null: false
    field :name, String, null: false
    field :race, Types::RaceEnum, null: false
    field :realm, String, null: true
    field :title, String, null: true
    field :ring_bearer, Boolean, null: false
    field :level, Integer, null: false
    field :xp, Integer, null: false
    field :strength, Integer, null: false
    field :wisdom, Integer, null: false
    field :endurance, Integer, null: false
    field :status, Types::CharacterStatusEnum, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
