# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "Event #{n}" }
  end
end
