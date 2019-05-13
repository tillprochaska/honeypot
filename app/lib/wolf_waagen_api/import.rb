# frozen_string_literal: true

module WolfWaagenApi
  class Import
    SENSOR_TYPES = [{
      property: 'Summierter Ertrag (Wolf Waagen API)',
      unit: 'kg',
      accuracy: 2,
      series_id: 'yield',
      accumulate: :daily
    }, {
      property: 'Ertrag (Wolf Waagen API)',
      unit: 'kg',
      accuracy: 2,
      series_id: 'yield'
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
      save_data(result: result)
    end

    def api_sensors
      @report.sensors.select do |sensor|
        SENSOR_TYPES.find do |type|
          sensor.sensor_type.property == type[:property] &&
            sensor.sensor_type.unit == type[:unit]
        end
      end
    end

    def save_data(result:)
      SENSOR_TYPES.each do |type|
        interval = type[:accumulate]
        sensors = sensors_by_type(type: type)
        series = result.series.find { |item| item.id == type[:series_id] }

        sensors.each do |sensor|
          save_series_data(series: series, sensor: sensor, interval: interval) if series
        end
      end
    end

    def save_series_data(series:, sensor:, interval: nil)
      series.points.each do |point|
        # binding.pry if sensor.id == 38

        value = point.data
        next if value.nil? # some values might be `nil`

        if interval
          value = accumulated_value(sensor: sensor, interval: interval, point: point)
        end
        
        # binding.pry if sensor.id == 38

        reading = Sensor::Reading.find_or_create_by(
          sensor: sensor,
          created_at: point.datetime,
          calibrated_value: value,
          uncalibrated_value: value
        )
      end
    end

    def sensors_by_type(type:)
      @report.sensors.select do |sensor|
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
        unless latest_reading_date
          start_date = @report.start_date
          # the start date's zimezone is UTC, local timezone
          # (e. g. Europe/Berlin) is needed
          start_date = Time.zone.local(start_date.year, start_date.month, start_date.day)
          latest_reading_date = start_date
        end

        date = latest_reading_date if date.nil? || latest_reading_date < date
      end

      date.to_datetime
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

      raise ArgumentError "Not a valid interval: #{interval}" unless intervals.key? interval

      range = intervals[interval]
      latest_record = sensor.sensor_readings.where(created_at: range).order('created_at').last
      latest_value = latest_record&.calibrated_value || 0
      
      latest_value + value
    end
  end
end
