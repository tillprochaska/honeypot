# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WolfWaagenApi::Request do
  describe '#initialize' do
    it 'validates start date/time' do
      expect do
        described_class.new(
          hive_id: 'HIVE_ID',
          start_date: DateTime.new,
          end_date: nil
        )
      end.to raise_error ArgumentError
    end

    it 'validates end date/time' do
      expect do
        described_class.new(
          hive_id: 'HIVE_ID',
          start_date: nil,
          end_date: DateTime.new
        )
      end.to raise_error ArgumentError
    end

    it 'validates interval' do
      expect do
        described_class.new(
          hive_id: 'HIVE_ID',
          start_date: DateTime.new,
          end_date: DateTime.new,
          interval: 'invalid_interval'
        )
      end.to raise_error ArgumentError
    end

    it 'defaults to hourly interval' do
      req = described_class.new(
        hive_id: 'HIVE_ID',
        start_date: DateTime.new,
        end_date: DateTime.new
      )

      expect(req.interval).to eql('hour')
    end
  end

  describe '#url' do
    it 'builds API url' do
      start_date = DateTime.new(2019, 0o1, 0o1)
      end_date = DateTime.new(2019, 0o1, 0o2)

      req = described_class.new(
        hive_id: 'HIVE_ID',
        start_date: start_date,
        end_date: end_date,
        interval: 'minute'
      )

      url = req.url

      expected =  'https://app.wolf-waagen.de/api/graph/stock/HIVE_ID'
      expected += '?end=1546387200000&interval=minute&navigator=false&start=1546300800000'

      expect(url).to eql(expected)
    end
  end
end
