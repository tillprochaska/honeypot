# frozen_string_literal: true

FactoryBot.define do
  factory :command do
    actuator nil
    function 'activate'
    executed false
  end
end
