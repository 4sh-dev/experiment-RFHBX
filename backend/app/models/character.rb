# frozen_string_literal: true

class Character < ApplicationRecord
  enum :status, { idle: "idle", on_quest: "on_quest", fallen: "fallen" }, default: "idle"

  has_many :quest_memberships, dependent: :destroy
  has_many :quests, through: :quest_memberships
  has_many :artifacts, dependent: :nullify

  validates :name, presence: true
  validates :race, presence: true
  validates :level, numericality: { greater_than: 0 }
  validates :xp, numericality: { greater_than_or_equal_to: 0 }
  validates :strength, numericality: { greater_than: 0 }
  validates :wisdom, numericality: { greater_than: 0 }
  validates :endurance, numericality: { greater_than: 0 }
end
