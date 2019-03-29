# frozen_string_literal: true

class AddAnnotationToSensorReadings < ActiveRecord::Migration[5.0]
  def change
    add_column :sensor_readings, :annotation, :string
  end
end
