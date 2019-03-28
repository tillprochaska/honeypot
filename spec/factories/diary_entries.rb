# frozen_string_literal: true

FactoryBot.define do
  factory :diary_entry do
    association :report
  end
end
