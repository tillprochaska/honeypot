require 'rails_helper'

RSpec.describe WolfWaagenApi::Result do

  before(:each) do
    @valid_req = WolfWaagenApi::Request.new(
      hive_id: 'HIVE_ID',
      start_date: DateTime.new,
      end_date: DateTime.new
    )

    @valid_res = WolfWaagenApi::Result.new(
      request: @valid_req,
      data: {
        pointStart: 1546300800000, # 2019-01-01 00:00:00
        pointInterval: 300000, # 5 minutes
        series: [{
          id: 'weight',
          unit: 'kg',
          accuracy: 2,
          values: [1, 2, 3, 4, 5]
        }]
      }
    )

    @valid_series = @valid_res.series[0]
  end

  describe '#initialize' do

    it 'validates series' do
      expect {
        WolfWaagenApi::Point.new(series: nil, index: 0, value: 100)
      }.to raise_error ArgumentError
    end

    it 'validates index' do
      expect {
        WolfWaagenApi::Point.new(
          series: @valid_series,
          index: 'strings not allowed',
          value: 100
        )
      }.to raise_error ArgumentError
    end

    it 'calculates date and time based on the series’ date and interval' do
      expect {
        point = WolfWaagenApi::Point.new(
          series: @valid_series,
          index: 3,
          value: 100
        )

        expected = 1546301100000 # 2019-01-01 00:05:00
        expect(point.datetime).to eql(expected)
      }
    end

  end

end