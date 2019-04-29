# frozen_string_literal: true

namespace :duplicate_report_data do
  desc 'Copies all text components (including associated entities) for the given report to the other reports'
  task :text_components, [:report_id] do |_task, args|
    raise 'Please enter a report to copy from' unless args[:report_id]

    source_report = Report.find(args[:report_id])
    other_reports = Report.where.not(id: args[:report_id])
    other_reports = other_reports.where.not(name: 'Testbienenstock')

    other_reports.each do |other_report|
      puts "Duplicating text components for report \"#{other_report.name}\" …"

      source_report.text_components.each do |original_text_component|
        find_or_create_text_component(other_report, original_text_component)
      end
    end
  end

  # Finds or creates a text component in `target_report` using
  # an existing text component of another report. Instead of cloning
  # a text component, this methods creates a fresh text component and
  # explicitly copy some attributes and relations (i. e. triggers)
  # from `original_trigger. This is in order to prevent that relations
  # to associated records accidentally get copied, but not cloned.
  def find_or_create_text_component(target_report, original_text_component)
    unique_cols = %w[
      created_at
      heading introduction main_part closing
      from_day to_day from_hour to_hour
      topic_id publication_status assignee_id notes
    ]

    data = pluck_from_hash(original_text_component.attributes, unique_cols)
    text_component = target_report.text_components.find_or_create_by data
    text_component.report_id = target_report.id

    # Channels are global to all text components, so we can just
    # copy them to the new text component.
    text_component.channel_ids = original_text_component.channel_ids

    text_component.save!

    original_text_component.triggers.each do |original_trigger|
      trigger = find_or_create_trigger(target_report, original_trigger)
      text_component.triggers << trigger
    end

    text_component.save!

    text_component
  end

  # Similar to `find_or_copy_text_component`, this creates finds an existing
  # trigger or creates a fresh one, copying some attributes and relations
  # from `original_trigger`.
  def find_or_create_trigger(target_report, original_trigger)
    unique_cols = %w[created_at name priority validity_period]
    data = pluck_from_hash(original_trigger.attributes, unique_cols)
    trigger = target_report.triggers.find_or_create_by! data
    trigger.report_id = target_report.id

    trigger.save!

    original_trigger.conditions.each do |original_condition|
      condition = create_condition(trigger, original_condition)
      trigger.conditions << condition
    end

    # For some reason, events are global to all reports. Thus we do not
    # need to duplicate these events.
    trigger.event_ids = original_trigger.event_ids

    trigger.save!

    trigger
  end

  # Creates a new condition in `target_report`, based on `original_condition`.
  def create_condition(target_trigger, original_condition)
    unique_cols = %w[created_at from to]
    data = pluck_from_hash(original_condition.attributes, unique_cols)

    # Conditions do not have enough data on their own to uniquely identify
    # them, so we need to use the sensor's type as well.
    original_sensor = original_condition.sensor
    sensor = target_trigger.report.sensors.find_by(sensor_type: original_sensor.sensor_type)

    # This task assumes that sensors for all reports already exist and
    # do not need to be created.
    raise "Could not find sensor \"#{original_sensor.sensor_type.property}\" in report #{target_report.name}" unless sensor

    data['sensor_id'] = sensor.id

    # Conditions belong to a single trigger only, so we can create a new
    # one here without checking if there might already be one existing.
    condition = target_trigger.conditions.create! data
    condition.save!

    condition
  end

  def pluck_from_hash(hash, keys)
    hash.select do |key, _val|
      keys.include? key
    end
  end
end
