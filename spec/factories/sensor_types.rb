# frozen_string_literal: true

FactoryBot.define do
  factory :sensor_type do
    property { 'MyString' }
    unit { 'MyString' }
    fractionDigits { 1 }
  end
end
