# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WolfWaagenApi::Series do
  let(:valid_req) do
    WolfWaagenApi::Request.new(
      hive_id: 'HIVE_ID',
      start_date: DateTime.new(2019, 0o1, 0o1, 0o0, 0o0),
      end_date: DateTime.new(2019, 0o1, 0o1, 0o0, 0o5)
    )
  end

  let(:valid_res) do
    WolfWaagenApi::Result.new(
      request: valid_req,
      data: {
        pointStart: 1546300500000, # 2018-12-31 23:55:00
        pointInterval: 300000,
        series: []
      }
    )
  end

  let(:valid_data) do
    {
      id: 'weight',
      unit: 'kg',
      accuracy: 2,
      values: [1.023, 2, 3]
    }
  end

  describe '#initialize' do
    it 'validates result' do
      expect do
        described_class.new(result: nil, data: valid_data)
      end.to raise_error ArgumentError
    end

    it 'validates id' do
      data = valid_data.clone
      data[:id] = nil

      expect do
        described_class.new(result: valid_res, data: data)
      end.to raise_error ArgumentError
    end

    it 'allows unitless series' do
      data = valid_data.clone
      data[:unit] = nil

      expect do
        described_class.new(result: valid_res, data: data)
      end.not_to raise_error
    end

    it 'allows series without accuracy' do
      data = valid_data.clone
      data[:accuracy] = nil

      expect do
        described_class.new(result: valid_res, data: data)
      end.not_to raise_error
    end

    it 'makes sure a list of float or integer values is passed' do
      data = valid_data.clone
      data[:values] = 123

      expect do
        described_class.new(result: valid_res, data: data)
      end.to raise_error
    end

    it 'handles a list of float or integer values' do
      expect do
        described_class.new(result: valid_res, data: valid_data)
      end.not_to raise_error
    end

    it 'wraps data points in `Point` objects' do
      series = described_class.new(result: valid_res, data: valid_data)
      expect(series.points).to all(be_a(WolfWaagenApi::Point))
    end

    it 'ensure only points in the specified time range are returned' do
      series = described_class.new(result: valid_res, data: valid_data)
      points = series.points.map(&:data)

      expect(points).to eql([2])
    end
  end
end
