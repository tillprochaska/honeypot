# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WolfWaagenApi::Point do
  let(:valid_req) do
    WolfWaagenApi::Request.new(
      hive_id: 'HIVE_ID',
      start_date: DateTime.new,
      end_date: DateTime.new
    )
  end

  let(:valid_res) do
    WolfWaagenApi::Result.new(
      request: valid_req,
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
  end

  let(:valid_series) do
    valid_res.series[0]
  end

  describe '#initialize' do
    it 'validates series' do
      expect do
        described_class.new(series: nil, index: 0, data: 100)
      end.to raise_error ArgumentError
    end

    it 'validates index' do
      expect do
        described_class.new(
          series: valid_series,
          index: 'strings not allowed',
          data: 100
        )
      end.to raise_error ArgumentError
    end

    it 'calculates date and time based on the series’ date and interval' do
      point = described_class.new(
        series: valid_series,
        index: 3,
        data: 100
      )

      expected = DateTime.new(2019, 1, 1, 0, 15, 0)
      expect(point.datetime).to eql(expected)
    end
  end
end
