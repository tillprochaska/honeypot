# frozen_string_literal: true

module WolfWaagenApi
  class Import

    SENSOR_TYPES = [{
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
    }]

    def initialize(report: report)
      raise ArgumentError.new('`report` should have an `hive_id` attribute.') unless report.hive_id
      @report = report
    end

    def run
      request = Request.new(
        hive_id: @report.hive_id,
        start_date: self.start_date,
        end_date: DateTime.now
      )

      result = request.send
      result.series.each do |series|
        self.save_series_points(series)
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

    def api_sensors_by_series_id(series_id: series_id)
      type = SENSOR_TYPES.find { |type| type[:series_id] == series_id }

      sensors = self.api_sensors.select do |sensor|
        # some of the data series the API returns might
        # not have mappings to sensor types in the story board
        type &&
        sensor.sensor_type.property == type[:property] &&
        sensor.sensor_type.unit == type[:unit]
      end
    end

    def start_date
      date = nil

      self.api_sensors.each do |sensor|
        latest_reading_date = sensor.sensor_readings.maximum(:created_at)

        # If no readings have been imported yet, fetch readings
        # since the beginning of the report
        if not latest_reading_date
          latest_reading_date = @report.start_date
        end

        if date.nil? || latest_reading_date < date
          date = latest_reading_date
        end
      end

      date.to_datetime
    end

    def save_series_points(series)
      sensors = self.api_sensors_by_series_id(series_id: series.id)

      sensors.each do |sensor|
        series.points.each do |point|
          Sensor::Reading.find_or_create_by(
            sensor: sensor,
            created_at: point.datetime,
            calibrated_value: point.data,
            uncalibrated_value: point.data
          )
        end
      end
    end

  end
end
