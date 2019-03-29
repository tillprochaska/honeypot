module WolfWaagenApi

  class Result

    attr_accessor :earliest_date, :interval
    delegate :hive_id, :start_date, :end_date, to: :@request

    def initialize(request:, data:)
      if not request.is_a? Request
        raise ArgumentError.new('`request` should be an instance of `Request`.')
      end

      @request = request

      if not data[:pointStart].is_a? Integer
        raise ArgumentError.new('`data.pointStart` should be an milliseconds timestamp.')
      end

      @earliest_date = Time.at(data[:pointStart] / 1000).to_datetime

      if not data[:pointInterval].is_a? Integer
        raise ArgumentError.new('`data.pointInterval` should be the measurement interval in milliseconds.')
      end

      @interval = data[:pointInterval]

      if not data[:series].is_a?(Array)
        raise ArgumentError.new('`data.series` should be a list of series data.')
      end

      @raw_series = data[:series]

    end

    def series
      @raw_series
        .select { | series | series[:values].is_a? Array }
        .map { | series | Series.new(result: self, data: series) }
    end

  end

end