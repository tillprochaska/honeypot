module WolfWaagenApi

  class Series

    attr_accessor :id, :unit, :accuracy
    delegate :hive_id, :start_date, :end_date, :interval, :earliest_date, to: :@result

    def initialize(result:, data:)
      if not result.is_a? Result
        raise ArgumentError.new('`result` should be an instance of `Result`.')
      end

      @result = result

      if not data[:id]
        raise ArgumentError.new('`data` should have an `id` property.')
      end

      @id = data[:id]
      @unit = data[:unit]
      @accuracy = data[:accuracy]

      if not data[:values].is_a?(Array)
        raise ArgumentError.new('`data.values` should be a list of series data')
      end

      @values = data[:values]
    end

    def points
      points = @values.map.with_index { | value, index | 
        Point.new(series: self, index: index, data: value)
      }

      # As the API’s optimized for displaying a data graph, it might return
      # values that outside of the specified range
      points.select { | point | 
        self.start_date <= point.datetime && point.datetime < self.end_date
      }
    end

  end

end