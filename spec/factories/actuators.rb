# frozen_string_literal: true

FactoryBot.define do
  factory :actuator do
    name { 'MyString' }
    port { 1 }
  end
end
