# frozen_string_literal: true

require 'net/http'
require 'json'

module WolfWaagenApi
  VALID_INTERVALS = %w[minute hour day month].freeze
  API_HOST = 'app.wolf-waagen.de'
  API_BASE_PATH = '/api/graph/stock/'

  class Request
    attr_accessor :hive_id, :interval, :start_date, :end_date

    def initialize(hive_id:, start_date:, end_date:, interval: 'hour')
      @hive_id = hive_id

      raise ArgumentError, '`start_date` and `end_date` should be instances of `DateTime`.' unless [start_date, end_date].all? DateTime

      @start_date = start_date
      @end_date = end_date

      raise ArgumentError, '`interval` should be either `minute`, `hour`, `day` or `month`.' unless VALID_INTERVALS.include? interval

      @interval = interval
    end

    def url
      params = {
        start: start_date.strftime('%Q'),
        end: end_date.strftime('%Q'),
        interval: interval,
        navigator: false
      }

      URI::HTTPS.build(
        host: API_HOST,
        path: API_BASE_PATH + hive_id,
        query: params.to_query
      ).to_s
    end

    def send
      uri = URI(url)
      res = Net::HTTP.get_response(uri)

      raise ArgumentError, 'Hive not found.' if res.code == 404

      raise 'Could not fetch data for unknown reasons.' if res.code != '200'

      data = JSON.parse(res.body, symbolize_names: true)
      Result.new(request: self, data: data)
    end
  end
end
