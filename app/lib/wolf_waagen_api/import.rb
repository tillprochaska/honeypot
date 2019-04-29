# frozen_string_literal: true

module WolfWaagenApi
  class Import
    SENSOR_TYPES = [{
      property: 'Ertrag (Wolf Waagen API)',
      unit: 'kg',
      accuracy: 2,
      series_id: 'yield',
      accumulate: :daily
    }, {
      property: 'Außentemperatur (Wolf Waagen API)',
      unit: '°C',
      accuracy: 1,
      series_id: 'temperature'
    }, {
      property: 'Brutrauminnentemperatur (Wolf Waagen API)',
      unit: '°C',
      accuracy: 1,
      series_id: 'brood0'
    }, {
      property: 'Luftfeuchtigkeit (Wolf Waagen API)',
      unit: '%',
      accuracy: 0,
      series_id: 'humidity'
    }, {
      property: 'Regen (Wolf Waagen API)',
      unit: 'mm',
      accuracy: 1,
      series_id: 'rain'
    }, {
      property: 'Windgeschwindigkeit (Wolf Waagen API)',
      unit: 'km/h',
      accuracy: 1,
      series_id: 'wind_speed'
    }, {
      property: 'Windböen (Wolf Waagen API)',
      unit: 'km/h',
      accuracy: 1,
      series_id: 'wind_gust'
    }].freeze

    def initialize(report:)
      raise ArgumentError, '`report` should be an instance of `Report`' unless report.is_a? Report
      raise ArgumentError, '`report` should have an `hive_id` attribute.' unless report.hive_id

      @report = report
    end

    def run
      request = Request.new(
        hive_id: @report.hive_id,
        start_date: start_date,
        end_date: DateTime.now
      )

      result = request.send
      result.series.each do |series|
        save_series_points(series: series)
      end
    end

    def api_sensors
      @report.sensors.select do |sensor|
        SENSOR_TYPES.find do |type|
          sensor.sensor_type.property == type[:property] &&
            sensor.sensor_type.unit == type[:unit]
        end
      end
    end

    def api_sensors_by_series_id(series_id:)
      type = SENSOR_TYPES.find { |t| t[:series_id] == series_id }

      api_sensors.select do |sensor|
        # some of the data series the API returns might
        # not have mappings to sensor types in the story board
        type &&
          sensor.sensor_type.property == type[:property] &&
          sensor.sensor_type.unit == type[:unit]
      end
    end

    def start_date
      date = nil

      api_sensors.each do |sensor|
        latest_reading_date = sensor.sensor_readings.maximum(:created_at)

        # If no readings have been imported yet, fetch readings
        # since the beginning of the report
        latest_reading_date ||= @report.start_date

        date = latest_reading_date if date.nil? || latest_reading_date < date
      end

      date.to_datetime
    end

    def save_series_points(series:)
      sensors = api_sensors_by_series_id(series_id: series.id)
      interval = accumulation_interval_by_series_id(series_id: series.id)

      sensors.each do |sensor|
        series.points.each do |point|
          value = accumulated_value(sensor: sensor, interval: interval, point: point)

          Sensor::Reading.find_or_create_by(
            sensor: sensor,
            created_at: point.datetime,
            calibrated_value: value,
            uncalibrated_value: value
          )
        end
      end
    end

    def accumulation_interval_by_series_id(series_id:)
      type = SENSOR_TYPES.find { |t| t[:series_id] == series_id }
      type[:accumulate] if type&.key?(:accumulate)
    end

    def accumulated_value(sensor:, interval:, point:)
      date = point.datetime
      value = point.data

      intervals = {
        daily: date.beginning_of_day..date,
        weekly: date.beginning_of_week..date,
        monthly: date.beginning_of_month..date,
        quarterly: date.beginning_of_quarter..date,
        yearly: date.beginning_of_year..date
      }

      return value unless intervals.key? interval

      range = intervals[interval]
      latest_record = sensor.sensor_readings.where(created_at: range).order('created_at').last

      return latest_record.calibrated_value + value if latest_record

      value
    end
  end
end
