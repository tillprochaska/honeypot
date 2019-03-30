namespace :wolf_waagen_api do

  SENSOR_TYPES = [{
    property: 'Ertrag (Wolf Waagen API)',
    unit: 'kg',
    accuracy: 2,
    series_name: 'yield'
  }, {
    property: 'Außentemperatur (Wolf Waagen API)',
    unit: '°C',
    accuracy: 1,
    series_name: 'temperature',
  }, {
      property: 'Brutrauminnentemperatur (Wolf Waagen API)',
      unit: '°C',
      accuracy: 1,
      series_name: 'brood0'
    }, {
      property: 'Luftfeuchtigkeit (Wolf Waagen API)',
      unit: '%',
      accuracy: 0,
      series_name: 'humidity'
    }, {
      property: 'Regen (Wolf Waagen API)',
      unit: 'mm',
      accuracy: 1,
      series_name: 'rain'
    }, {
      property: 'Windgeschwindigkeit (Wolf Waagen API)',
      unit: 'km/h',
      accuracy: 1,
      series_name: 'wind_speed'
    }, {
      property: 'Windböen (Wolf Waagen API)',
      unit: 'km/h',
      accuracy: 1,
      series_name: 'wind_gust'
    }]

  desc "Set up sensor types for Wolf Waagen sensors."
  task setup: :environment do
    SENSOR_TYPES.each { | type |
      SensorType.find_or_create_by({
      property: type[:property],
      unit: type[:unit],
      data_collection_method: :automatic
    })
    }
  end

  desc "Fetch senor readings for all Wolf Waagen sensors."
  task fetch: :environment do
    Report.find_each do |report|
      next unless report.hive_id
      wolf_waagen_sensors = report.sensors.select do |s|
        SENSOR_TYPES.map{|t| t[:property]}.include?(s.property)
      end
      last_crawled_date = Sensor::Reading.where(sensor_id: wolf_waagen_sensors.map(&:id)).maximum(:created_at)
      last_crawled_date ||= report.start_date
      last_crawled_date = last_crawled_date.to_datetime
      request = WolfWaagenApi::Request.new(hive_id: report.hive_id, start_date: last_crawled_date, end_date: DateTime.now)
      result = request.send
      series =  result.series
      series.each do |series_item|
        series_item_sensor_type = SENSOR_TYPES.find{|t| t[:series_name] == series_item.id }
        next unless series_item_sensor_type
        matched_sensor = wolf_waagen_sensors.find {|s| s.sensor_type.property == series_item_sensor_type[:property] }
        next unless matched_sensor
        series_item.points.each do |point|
          Sensor::Reading.find_or_create_by(sensor: matched_sensor, created_at: point.datetime, calibrated_value: point.data, uncalibrated_value: point.data)
        end
      end
    end
  end
end
