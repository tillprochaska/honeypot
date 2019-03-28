# frozen_string_literal: true

class MakeSensorNameUnique < ActiveRecord::Migration
  def change
    add_index :sensors, :name, unique: true
  end
end
