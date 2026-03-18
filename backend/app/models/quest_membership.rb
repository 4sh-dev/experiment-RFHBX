# frozen_string_literal: true

class QuestMembership < ApplicationRecord
  belongs_to :character
  belongs_to :quest

  validates :character, presence: true
  validates :quest, presence: true
  validates :character_id, uniqueness: { scope: :quest_id, message: "is already a member of this quest" }
end
