# frozen_string_literal: true

class AddAnimalIdToSensors < ActiveRecord::Migration[5.0]
  def change
    add_column :sensors, :animal_id, :string
  end
end
