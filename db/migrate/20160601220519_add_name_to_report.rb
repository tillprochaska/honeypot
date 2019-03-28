# frozen_string_literal: true

class AddNameToReport < ActiveRecord::Migration
  def change
    add_column :reports, :name, :string
  end
end
