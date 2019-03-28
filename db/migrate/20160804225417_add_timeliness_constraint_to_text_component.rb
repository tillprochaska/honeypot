# frozen_string_literal: true

class AddTimelinessConstraintToTextComponent < ActiveRecord::Migration
  def change
    add_column :text_components, :timeliness_constraint, :integer
  end
end
