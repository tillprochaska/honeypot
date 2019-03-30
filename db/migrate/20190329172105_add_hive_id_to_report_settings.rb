# frozen_string_literal: true

class AddHiveIdToReportSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :hive_id, :string
  end
end
