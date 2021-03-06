# frozen_string_literal: true

class AddMinMaxFractionDigitsToSensorTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :sensor_types, :min, :decimal, default: -20.0
    add_column :sensor_types, :max, :decimal, default: 100.0
    add_column :sensor_types, :fractionDigits, :integer, default: 0
    change_column_default :sensor_types, :unit, ''
  end
end
