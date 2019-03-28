# frozen_string_literal: true

class AddDeviceIdToSensors < ActiveRecord::Migration[5.0]
  def change
    add_column :sensors, :device_id, :string
  end
end
