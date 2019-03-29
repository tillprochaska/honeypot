# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    frontend_base_url { 'http://bienenlive.wdr.de/koenigin/' }
    name { 'My Sensor-Live-Report' }
    start_date { '2016-06-01 16:11:28' }
  end
end
