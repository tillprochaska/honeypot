# frozen_string_literal: true

FactoryBot.define do
  factory :variable do
    key { 'MyString' }
    value { 'MyString' }
    report { nil }
  end
end
