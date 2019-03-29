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

  end

end
