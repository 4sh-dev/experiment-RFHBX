# frozen_string_literal: true

FactoryBot.define do
  factory :quest_membership do
    association :character
    association :quest
    role { %w[leader scout healer warrior].sample }
  end
end
