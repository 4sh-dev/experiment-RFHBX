# frozen_string_literal: true

module Types
  class SimulationModeEnum < Types::BaseEnum
    description "The simulation operating mode"

    value "CAMPAIGN", "Run a structured campaign sequence", value: "campaign"
    value "RANDOM", "Generate quests at random", value: "random"
  end
end
