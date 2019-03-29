require 'rails_helper'

RSpec.describe WolfWaagenApi::Request do

  describe '#initialize' do

    it 'validates start date/time' do
      expect {
        WolfWaagenApi::Request.new(
          hive_id: 'HIVE_ID',
          start_date: DateTime.new,
          end_date: nil
        )
      }.to raise_error ArgumentError
    end

    it 'validates end date/time' do
      expect {
        WolfWaagenApi::Request.new(
          hive_id: 'HIVE_ID',
          start_date: nil,
          end_date: DateTime.new
        )
      }.to raise_error ArgumentError
    end

    it 'validates interval' do 
      expect {
        WolfWaagenApi::Request.new(
          hive_id: 'HIVE_ID',
          start_date: DateTime.new,
          end_date: DateTime.new,
          interval: 'invalid_interval'
        )
      }.to raise_error ArgumentError
    end

    it 'defaults to hourly interval' do
      req = WolfWaagenApi::Request.new(
        hive_id: 'HIVE_ID',
        start_date: DateTime.new,
        end_date: DateTime.new
      )

      expect(req.interval).to eql('hour')
    end

  end

  describe '#url' do

    it 'builds API url' do
      start_date = DateTime.new(2019, 01, 01)
      end_date = DateTime.new(2019, 01, 02)

      req = WolfWaagenApi::Request.new(
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