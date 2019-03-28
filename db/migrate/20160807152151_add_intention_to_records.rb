# frozen_string_literal: true

class AddIntentionToRecords < ActiveRecord::Migration
  def change
    add_column :records, :intention, :integer, default: 0
  end
end
