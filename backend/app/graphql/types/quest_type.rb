# frozen_string_literal: true

module Types
  class QuestType < Types::BaseObject
    description "A quest that characters can undertake in Middle-earth"

    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :status, Types::QuestStatusEnum, null: false
    field :danger_level, Integer, null: false
    field :region, Types::RegionEnum, null: true
    field :progress, Float, null: false
    field :success_chance, Float, null: true
    field :quest_type, Types::QuestTypeEnum, null: false
    field :campaign_order, Integer, null: true
    field :attempts, Integer, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
