# frozen_string_literal: true

module Types
  class CharacterStatusEnum < Types::BaseEnum
    description "The current status of a character"

    value "IDLE", "Character is not on a quest", value: "idle"
    value "ON_QUEST", "Character is currently on a quest", value: "on_quest"
    value "FALLEN", "Character has died", value: "fallen"
  end
end
