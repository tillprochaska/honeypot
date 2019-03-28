# frozen_string_literal: true

class Actuator < ActiveRecord::Base
  has_many :commands
  validates :name, presence: true, uniqueness: true

  def activate!(synchronous: false)
    c = Command.create!(actuator: self, function: :activate)
    c.run! if synchronous
  end

  def deactivate!(synchronous: false)
    c = Command.create!(actuator: self, function: :deactivate)
    c.run! if synchronous
  end
end
