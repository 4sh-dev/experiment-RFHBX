# frozen_string_literal: true

FactoryBot.define do
  factory :quest_event do
    association :quest
    event_type { :started }
    message { "The quest has begun." }
    data { {} }

    trait :progress do
      event_type { :progress }
      message { "The fellowship advances." }
      data { { "progress" => 0.5 } }
    end

    trait :completed do
      event_type { :completed }
      message { "The quest is complete!" }
      data { { "progress" => 1.0 } }
    end

    trait :failed do
      event_type { :failed }
      message { "The quest has failed." }
      data { { "reason" => "overwhelmed" } }
    end

    trait :restarted do
      event_type { :restarted }
      message { "The quest has been restarted." }
      data { {} }
    end
  end
end
