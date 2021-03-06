# frozen_string_literal: true

class Event::Activation < ApplicationRecord
  belongs_to :event, required: true

  validates :started_at, presence: true
  validate :ends_after_start
  validate :not_overlapping

  scope :before, ->(time) { where('started_at <= ?', time) }
  scope :active, ->(time) { before(time).where('ended_at IS NULL OR ended_at > ?', time) }

  def duration
    ended_at && ended_at - started_at
  end

  def active?
    ended_at.nil?
  end

  private

  def ends_after_start
    if ended_at && started_at && (ended_at < started_at)
      errors.add(:ended_at, "can't end before started")
    end
  end

  def not_overlapping
    if started_at
      overlapping_activation = Event::Activation.where(event: event).where.not(id: id).where('ended_at > ?', started_at)
      if ended_at
        overlapping_activation = overlapping_activation.where('started_at < ?', ended_at)
      end
      unless overlapping_activation.empty?
        errors.add(:started_at, 'time span overlaps with another activation')
        errors.add(:ended_at, 'time span overlaps with another activation')
      end
    end
  end
end
