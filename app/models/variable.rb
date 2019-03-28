# frozen_string_literal: true

class Variable < ActiveRecord::Base
  validates :key, presence: true, uniqueness: { scope: :report_id }
  belongs_to :report
end
