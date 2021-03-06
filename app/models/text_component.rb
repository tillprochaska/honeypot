# frozen_string_literal: true

class TextComponent < ActiveRecord::Base
  TIME_FRAMES = {
    'always' => [nil, nil].to_json,
    '(06:00 - 09:00) in the morning' => [6, 9].to_json,
    '(09:00 - 13:00) before noon' => [9, 13].to_json,
    '(13:00 - 18:00) afternoons' => [13, 18].to_json,
    '(18:00 - 00:00) evenings' => [18, 0].to_json,
    '(00:00 - 06:00) nights' => [0, 6].to_json
  }.freeze

  attr_accessor :delete_image
  before_validation { image.clear if delete_image == '1' }

  # This method associates the attribute ":image" with a file attachment
  has_attached_file :image, styles: {
    small: '620>',
    big: '1000>'
  }

  def image_url_big
    image.url(:big)
  end

  def image_url_small
    image.url(:small)
  end

  validates :heading, :report, presence: true
  validates :from_hour, inclusion: { in: 0..23 }, allow_blank: true
  validates :to_hour, inclusion: { in: 0..23 }, allow_blank: true
  validate :both_hours_are_given
  has_and_belongs_to_many :triggers
  has_many :sensors, through: :triggers
  has_many :events, through: :triggers
  has_and_belongs_to_many :channels
  belongs_to :report
  belongs_to :topic
  belongs_to :assignee, class_name: 'User'
  has_many :question_answers, inverse_of: :text_component, dependent: :destroy
  accepts_nested_attributes_for :question_answers, reject_if: :all_blank, allow_destroy: true

  accepts_nested_attributes_for :triggers

  validates :channels, presence: true
  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment :image,
                       content_type: { content_type: %r{\Aimage/.*\z} },
                       size: { in: 0..20.megabytes }

  delegate :name, to: :topic, prefix: true, allow_nil: true
  delegate :name, to: :assignee, prefix: true, allow_nil: true

  enum publication_status: { draft: 0, fact_checked: 1, published: 2 }

  def timeframe=(frame)
    arr = JSON.parse(frame)
    self.from_hour, self.to_hour = * arr
  end

  def timeframe
    [from_hour, to_hour].to_json
  end

  def displayed_timeframe
    label = TextComponent::TIME_FRAMES.invert[timeframe]
    label&.split(') ')&.last
  end

  def active?(diary_entry)
    on_time?(diary_entry) && triggers.all? { |t| t.active?(diary_entry) }
  end

  def on_time?(diary_entry)
    result = true
    if from_day
      result &= ((report.start_date + from_day.days) <= diary_entry.moment.to_date)
    end
    if to_day
      result &= (diary_entry.moment.to_date <= (report.start_date + to_day.days))
    end

    if from_hour && to_hour
      if from_hour <= to_hour
        result &= (from_hour <= diary_entry.moment.hour) && (diary_entry.moment.hour < to_hour)
      else
        # e.g. 21:00 -> 6:00
        result &= (diary_entry.moment.hour < to_hour) || (from_hour <= diary_entry.moment.hour)
      end
    end
    result
  end

  def priority_index
    Trigger.priorities[priority]
  end

  def priority
    most_important_trigger = triggers.sort_by { |t| Trigger.priorities[t.priority] }.reverse.first
    most_important_trigger&.priority
  end

  def image_url
    image&.url
  end

  private

  def both_hours_are_given
    errors.add(:to_hour, 'is missing') if from_hour && to_hour.blank?
    errors.add(:from_hour, 'is missing') if to_hour && from_hour.blank?
  end
end
