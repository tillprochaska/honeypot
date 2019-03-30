# frozen_string_literal: true

json.extract! @sensor_reading, :id, :created_at, :calibrated_value, :uncalibrated_value, :annotation, :release
