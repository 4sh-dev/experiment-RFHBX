# frozen_string_literal: true

FactoryBot.define do
  factory :artifact do
    sequence(:name) { |n| "#{%w[Ring\ of\ Power Sting Glamdring Andúril Phial\ of\ Galadriel].sample rescue "Artifact"} #{n}" }
    artifact_type { %w[ring sword staff shield amulet].sample }
    power { "A powerful artifact from the age of legends." }
    corrupted { false }
    character { nil }
    stat_bonus { {} }

    trait :corrupted do
      corrupted { true }
    end

    trait :with_owner do
      association :character
    end

    trait :with_stat_bonus do
      stat_bonus { { "strength" => 5, "wisdom" => 3 } }
    end
  end
end
