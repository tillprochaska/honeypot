# frozen_string_literal: true

class AddUniqueConstraintToChannel < ActiveRecord::Migration[5.0]
  def change
    add_index :channels, :name, unique: true
  end
end
