# frozen_string_literal: true

class QuestEvent < ApplicationRecord
  enum :event_type, {
    started: "started",
    progress: "progress",
    completed: "completed",
    failed: "failed",
    restarted: "restarted"
  }

  belongs_to :quest

  validates :quest, presence: true
  validates :event_type, presence: true
end
