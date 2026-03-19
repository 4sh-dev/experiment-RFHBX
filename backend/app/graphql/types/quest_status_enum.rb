# frozen_string_literal: true

module Types
  class QuestStatusEnum < Types::BaseEnum
    description "The current status of a quest"

    value "PENDING", "Quest has not yet started", value: "pending"
    value "ACTIVE", "Quest is in progress", value: "active"
    value "COMPLETED", "Quest has been completed successfully", value: "completed"
    value "FAILED", "Quest has failed", value: "failed"
  end
end
