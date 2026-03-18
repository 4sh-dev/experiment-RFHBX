# frozen_string_literal: true

class Artifact < ApplicationRecord
  belongs_to :character, optional: true

  validates :name, presence: true
  validates :artifact_type, presence: true

  attribute :stat_bonus, :jsonb, default: {}
end
