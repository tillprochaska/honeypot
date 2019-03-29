require 'rails_helper'

RSpec.describe WolfWaagenApi::Series do

  before(:each) do
    @valid_req = WolfWaagenApi::Request.new(
      hive_id: 'HIVE_ID',
      start_date: DateTime.new(2019, 01, 01, 00, 00),
      end_date: DateTime.new(2019, 01, 01, 00, 05)
    )

    @valid_res = WolfWaagenApi::Result.new(
      request: @valid_req,
      data: {
        pointStart: 1546300500000, # 2018-12-31 23:55:00
        pointInterval: 300000,
        series: []
      }
    )

    @valid_data = {
      id: 'weight',
      unit: 'kg',
      accuracy: 2,
      values: [1.023, 2, 3]
    }
  end

  describe '#initialize' do

    it 'validates result' do
      expect {
        WolfWaagenApi::Series.new(result: nil, data: @valid_data)
      }.to raise_error ArgumentError
    end

    it 'validates id' do
      data = @valid_data.clone
      data[:id] = nil

      expect {
        WolfWaagenApi::Series.new(result: @valid_res, data: data)
      }.to raise_error ArgumentError
    end

    it 'should allow unitless series' do
      data = @valid_data.clone
      data[:unit] = nil

      expect {
        WolfWaagenApi::Series.new(result: @valid_res, data: data)
      }.not_to raise_error
    end

    it 'should allow series without accuracy' do
      data = @valid_data.clone
      data[:accuracy] = nil

      expect {
        WolfWaagenApi::Series.new(result: @valid_res, data: data)
      }.not_to raise_error
    end

    it 'makes sure a list of float or integer values is passed' do
      data = @valid_data.clone
      data[:values] = 123

      expect {
        WolfWaagenApi::Series.new(result: @valid_res, data: data)
      }.to raise_error
    end

    it 'handles a list of float or integer values' do
      expect {
        WolfWaagenApi::Series.new(result: @valid_res, data: @valid_data)
      }.not_to raise_error
    end

    it 'wraps data points in `Point` objects' do
      series = WolfWaagenApi::Series.new(result: @valid_res, data: @valid_data)
      expect(series.points).to all(be_a(WolfWaagenApi::Point))
    end

    it 'ensure only points in the specified time range are returned' do
      series = WolfWaagenApi::Series.new(result: @valid_res, data: @valid_data)
      points = series.points.map { | point | point.data }

      expect(points).to eql([2])
    end

  end

end
