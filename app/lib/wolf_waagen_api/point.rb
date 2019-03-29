module WolfWaagenApi

  class Point

    attr_accessor :series, :index, :data
    delegate :id, to: :@series, prefix: :series # series_id
    delegate :unit, :accuracy, to: :@series

    def initialize(series:, index:, data:)
      if not series.is_a? Series
        raise ArgumentError.new('`series` should be an instance of `Series`.')
      end

      @series = series

      if not index.is_a? Integer
        raise ArgumentError.new('`index` should be an integer value.')
      end

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