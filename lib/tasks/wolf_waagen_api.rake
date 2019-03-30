# frozen_string_literal: true

namespace :wolf_waagen_api do
  desc 'Set up sensor types for Wolf Waagen sensors.'
  task setup: :environment do
    WolfWaagenApi::Import::SENSOR_TYPES.each do |type|
      SensorType.find_or_create_by(
        property: type[:property],
        unit: type[:unit],
        data_collection_method: :automatic
      )
    end
  end

  desc 'Fetch senor readings for all Wolf Waagen sensors.'
  task fetch: :environment do
    Report.find_each do |report|
      # reports might not have a hive scale associated
      # (e. g. for testing purposes)
      next unless report.hive_id

      import = WolfWaagenApi::Import.new(report: report)
      import.run
    end
  end
end
