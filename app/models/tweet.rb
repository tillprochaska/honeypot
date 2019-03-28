# frozen_string_literal: true

class Tweet < ActiveRecord::Base
  belongs_to :chain
  belongs_to :command

  validates :user, presence: true
  delegate :actuator, to: :chain, allow_nil: true
  delegate :function, to: :chain, allow_nil: true

  before_create :assign_chain
  after_create :create_command

  private

  def assign_chain
    unless chain
      self.chain = Chain.find_by(hashtag: main_hashtag) if main_hashtag
    end
  end

  def create_command
    if actuator
      self.command = Command.new(
        function: function,
        actuator: actuator,
        status: :pending,
        tweet: self
      )
      command.save
    end
  end
end
