# frozen_string_literal: true

class AddDurationToReport < ActiveRecord::Migration
  def change
    add_column :reports, :duration, :integer
  end
end
