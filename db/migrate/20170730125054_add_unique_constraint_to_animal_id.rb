# frozen_string_literal: true

class AddUniqueConstraintToAnimalId < ActiveRecord::Migration[5.0]
  def change
    add_index :sensors, %i[sensor_type_id animal_id], unique: true
  end
end
