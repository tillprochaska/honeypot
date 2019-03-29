require 'net/http'
require 'json'

module WolfWaagenApi

  VALID_INTERVALS = ['minute', 'hour', 'day', 'month']
  API_HOST = 'app.wolf-waagen.de'
  API_BASE_PATH = '/api/graph/stock/'

  class Request

    attr_accessor :hive_id, :interval, :start_date, :end_date

    def initialize(hive_id:, start_date:, end_date:, interval: 'hour')
      @hive_id = hive_id

      if not [start_date, end_date].all? DateTime
        raise ArgumentError.new('`start_date` and `end_date` should be instances of `DateTime`.')
      end

      @start_date = start_date
      @end_date = end_date

      if not VALID_INTERVALS.include? interval
        raise ArgumentError.new('`interval` should be either `minute`, `hour`, `day` or `month`.')
      end

      @interval = interval
    end

    def url
      params = {
        start: self.start_date.strftime('%Q'),
        end: self.end_date.strftime('%Q'),
        interval: self.interval,
        navigator: false
      }

      URI::HTTPS.build(
        host: API_HOST,
        path: API_BASE_PATH + self.hive_id,
        query: params.to_query
      ).to_s
    end

    def send
      uri = URI(self.url)
      res = Net::HTTP.get_response(uri)

      if res.code == 404
        raise ArgumentError.new('Hive not found.')
      end

      if not res.code == '200'
        raise 'Could not fetch data for unknown reasons.'
      end

      data = JSON.parse(res.body, { symbolize_names: true })
      Result.new(request: self, data: data)
    end

  end

end