# frozen_string_literal: true

module WolfWaagenApi
  class Point
    attr_accessor :series, :index, :data
    delegate :id, to: :@series, prefix: :series # series_id
    delegate :unit, :accuracy, to: :@series

    def initialize(series:, index:, data:)
      raise ArgumentError, '`series` should be an instance of `Series`.' unless series.is_a? Series

      @series = series

      raise ArgumentError, '`index` should be an integer value.' unless index.is_a? Integer

      @index = index
      @data = data
    end

    def datetime
      offset = @index * @series.interval
      # offset is a milliseconds value, seconds are required
      @series.earliest_date + (offset / 1000).seconds
    end
  end
end
