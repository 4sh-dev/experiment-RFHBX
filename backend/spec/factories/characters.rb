# frozen_string_literal: true

FactoryBot.define do
  factory :character do
    sequence(:name) { |n| "#{Faker::Fantasy::Tolkien.character} #{n}" }
    race { %w[Hobbit Elf Dwarf Man Wizard].sample }
    realm { Faker::Address.city }
    title { nil }
    ring_bearer { false }
    level { 1 }
    xp { 0 }
    strength { 5 }
    wisdom { 5 }
    endurance { 5 }
    status { :idle }

    trait :ring_bearer do
      ring_bearer { true }
      name { "Frodo Baggins" }
      race { "Hobbit" }
    end

    trait :fallen do
      status { :fallen }
    end

    trait :on_quest do
      status { :on_quest }
    end
  end
end
