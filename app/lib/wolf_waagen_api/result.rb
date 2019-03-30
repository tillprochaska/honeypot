# frozen_string_literal: true

module WolfWaagenApi
  class Result
    attr_accessor :earliest_date, :interval
    delegate :hive_id, :start_date, :end_date, to: :@request

    def initialize(request:, data:)
      raise ArgumentError, '`request` should be an instance of `Request`.' unless request.is_a? Request

      @request = request

      raise ArgumentError, '`data.pointStart` should be an milliseconds timestamp.' unless data[:pointStart].is_a? Integer

      @earliest_date = Time.at(data[:pointStart] / 1000).to_datetime

      raise ArgumentError, '`data.pointInterval` should be the measurement interval in milliseconds.' unless data[:pointInterval].is_a? Integer

      @interval = data[:pointInterval]

      raise ArgumentError, '`data.series` should be a list of series data.' unless data[:series].is_a?(Array)

      @raw_series = data[:series]
    end

    def series
      @raw_series
        .select { |series| series[:values].is_a? Array }
        .map { |series| Series.new(result: self, data: series) }
    end
  end
end
