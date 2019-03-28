# frozen_string_literal: true

class AddUniqueIndexToHashtag < ActiveRecord::Migration
  def change
    add_index :chains, :hashtag, unique: true
  end
end
