# frozen_string_literal: true

class RenameColumnSourceToIntention < ActiveRecord::Migration
  def change
    rename_column :sensor_readings, :source, :intention
  end
end
