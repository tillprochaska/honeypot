# frozen_string_literal: true

class ChangeStartDateTypeToDate < ActiveRecord::Migration
  def change
    change_column :reports, :start_date, :date
  end
end
