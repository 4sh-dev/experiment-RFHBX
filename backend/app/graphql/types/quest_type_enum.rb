# frozen_string_literal: true

module Types
  class QuestTypeEnum < Types::BaseEnum
    description "The type of quest"

    value "CAMPAIGN", "A campaign quest with a defined order", value: "campaign"
    value "RANDOM", "A randomly generated quest", value: "random"
  end
end
