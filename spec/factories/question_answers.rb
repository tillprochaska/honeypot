# frozen_string_literal: true

FactoryBot.define do
  factory :question_answer do
    question 'MyText'
    answer 'MyText'
    text_component nil
  end
end
