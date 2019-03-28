# frozen_string_literal: true

class AddSensorTypeToDeviceIdUniqueConstraint < ActiveRecord::Migration[5.0]
  def change
    remove_index :sensors, :device_id
    add_index :sensors, %i[sensor_type_id device_id], unique: true
  end
end
