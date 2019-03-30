# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WolfWaagenApi::Result do
  before(:each) do
    @valid_req = WolfWaagenApi::Request.new(
      hive_id: 'HIVE_ID',
      start_date: DateTime.new,
      end_date: DateTime.new
    )

    @valid_data = {
      pointStart: 1546297200000,
      pointInterval: 300000,
      series: [{
        id: 'weight',
        unit: 'kg',
        accuracy: 2,
        values: [1.023, 2, 3]
      }]
    }
  end

  describe '#initialize' do
    it 'validates request' do
      expect do
        WolfWaagenApi::Result.new(
          request: nil,
          data: @valid_data
        )
      end.to raise_error ArgumentError
    end

    it 'ensures the earliest date is given as a millisecond timestamp' do
      data = @valid_data
      data[:pointStart] = 1234.03

      expect do
        WolfWaagenApi::Result.new(
          request: @valid_req,
          data: data
        )
      end.to raise_error ArgumentError
    end

    it 'ensures the interval is given in milliseconds' do
      data = @valid_data
      data[:interval] = 'strings not allowed'
    end

    it 'removes raw series data without values' do
      data = @valid_data
      data[:series][0][:values] = nil

      res = WolfWaagenApi::Result.new(
        request: @valid_req,
        data: data
      )

      expect(res.series).to eql([])
    end
  end

  describe '#series' do
    it 'wraps measurement series in `Series` objects' do
      result = WolfWaagenApi::Result.new(
        request: @valid_req,
        data: @valid_data
      )

      expect(result.series).to all(be_a(WolfWaagenApi::Series))
    end
  end
end
