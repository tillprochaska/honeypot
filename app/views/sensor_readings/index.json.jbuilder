# frozen_string_literal: true

json.array!(@sensor_readings) do |sensor_reading|
  json.extract! sensor_reading, :id, :created_at, :calibrated_value, :uncalibrated_value, :annotation, :release
end
