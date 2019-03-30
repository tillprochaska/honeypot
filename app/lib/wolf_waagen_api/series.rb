# frozen_string_literal: true

module WolfWaagenApi
  class Series
    attr_accessor :id, :unit, :accuracy
    delegate :hive_id, :start_date, :end_date, :interval, :earliest_date, to: :@result

    def initialize(result:, data:)
      raise ArgumentError, '`result` should be an instance of `Result`.' unless result.is_a? Result

      @result = result

      raise ArgumentError, '`data` should have an `id` property.' unless data[:id]

      @id = data[:id]
      @unit = data[:unit]
      @accuracy = data[:accuracy]

      raise ArgumentError, '`data.values` should be a list of series data' unless data[:values].is_a?(Array)

      @values = data[:values]
    end

    def points
      points = @values.map.with_index do |value, index|
        Point.new(series: self, index: index, data: value)
      end

      # As the API's optimized for displaying a data graph, it might return
      # values that outside of the specified range
      points.select do |point|
        start_date <= point.datetime && point.datetime < end_date
      end
    end
  end
end
