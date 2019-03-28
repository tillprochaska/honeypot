# frozen_string_literal: true

class AddUniquenessConstraintToSensorAdress < ActiveRecord::Migration
  def change
    add_index :sensors, :address, unique: true
  end
end
