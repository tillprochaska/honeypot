# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

require 'rails_helper'

RSpec.describe WolfWaagenApi::Import do
  let(:report) do
    create(:report, hive_id: 'HIVE_ID', start_date: DateTime.new(2019, 1, 1))
  end

  let(:wolf_sensor_type) do
    specified_type = WolfWaagenApi::Import::SENSOR_TYPES.third
    create(:sensor_type, property: specified_type[:property], unit: specified_type[:unit])
  end

  let(:wolf_sensor) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Wolf Sensor 1', report: report)
  end

  let(:wolf_sensor2) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Wolf Sensor 2', report: report)
  end

  let(:import) { described_class.new(report: report) }

  let(:request) do
    WolfWaagenApi::Request.new(
      hive_id: 'HIVE_ID',
      start_date: DateTime.new(2019, 1, 1, 0, 0),
      end_date: DateTime.new(2019, 1, 3, 0, 0)
    )
  end

  let(:result) do
    WolfWaagenApi::Result.new(
      request: request,
      data: {
        pointStart: 1546300800000, # 2019-01-01 00:00:00
        pointInterval: 12.hours.in_milliseconds,
        series: [{
          # temperature
          id: WolfWaagenApi::Import::SENSOR_TYPES.third[:series_id],
          values: [10, 20, 30]
        }, {
          # yield
          id: WolfWaagenApi::Import::SENSOR_TYPES.first[:series_id],
          # we have a daily accumulation interval and 12 hours frequency for new sensor readings
          # so below, two values go together
          values: [10, 20, 30, 40]
        }, {
          # yield
          id: WolfWaagenApi::Import::SENSOR_TYPES.first[:series_id],
          values: [10, 0, nil, 30]
        }]
      }
    )
  end

  describe '#initialize' do
    let(:report_without_hive_id) do
      create(:report, hive_id: nil)
    end

    it 'validates report' do
      expect { described_class.new(report: nil) }.to raise_error ArgumentError
    end

    it 'ensures report has a `hive_id`' do
      expect { described_class.new(report: report_without_hive_id) }.to raise_error ArgumentError
    end
  end

  describe '#api_sensors' do
    subject { import.api_sensors }

    context 'given sensors of types not sepcified in constant' do
      let(:other_type) do
        create(:sensor_type, property: 'Other Sensor Type', unit: '')
      end

      let(:other_sensor) do
        create(:sensor, sensor_type: other_type, name: 'Other Sensor', report: report)
      end

      before do
        wolf_sensor
        other_sensor
      end

      it { is_expected.to eq([wolf_sensor]) }
    end

    context 'given sensor for other reports' do
      let(:other_report) do
        create(:report, hive_id: 'HIVE_ID2')
      end

      let(:other_sensor) do
        create(:sensor, sensor_type: wolf_sensor_type, name: 'Other Report’s Wolf Sensor', report: other_report)
      end

      before do
        wolf_sensor
        other_sensor
      end

      it { is_expected.to eq([wolf_sensor]) }
    end
  end

  describe '#start_date' do
    subject { import.start_date }

    let(:wolf_sensor_reading) do
      create(
        :sensor_reading,
        sensor: wolf_sensor,
        created_at: DateTime.new(2019, 1, 2),
        calibrated_value: 100,
        uncalibrated_value: 100
      )
    end

    let(:wolf_sensor_reading2) do
      create(
        :sensor_reading,
        sensor: wolf_sensor2,
        created_at: DateTime.new(2019, 1, 3),
        calibrated_value: 100,
        uncalibrated_value: 100
      )
    end

    context 'given no sensor readings for one of two sensors' do
      before do
        wolf_sensor
        wolf_sensor2
        wolf_sensor_reading
      end

      it 'returns the report start date with default time zone' do
        # time zone is Europe/Berlin, which has a one hour offset during winter
        is_expected.to eq(DateTime.new(2019, 1, 1, 0, 0, 0, '+0100'))
      end
    end

    context 'given sensor readings for all sensors' do
      before do
        wolf_sensor
        wolf_sensor2
        wolf_sensor_reading
        wolf_sensor_reading2
      end

      it 'returns the oldest latest sensor reading date' do
        is_expected.to eq(DateTime.new(2019, 1, 2))
      end
    end
  end

  describe '#save_data' do
    context 'given a single matching sensor' do
      subject { wolf_sensor.sensor_readings.order(:created_at).pluck(:calibrated_value) }

      before { wolf_sensor }

      context 'creates sensor readings' do
        before { import.save_data(result: result) }

        it { is_expected.to eq([10, 20, 30]) }
      end

      context 'does not create duplicate readings' do
        before do
          import.save_data(result: result)
          import.save_data(result: result)
        end

        it { is_expected.to eq([10, 20, 30]) }
      end
    end

    context 'given two sensors of the same sensor type' do
      before do
        wolf_sensor
        wolf_sensor2
      end

      it 'creates sensor readings for both sensors' do
        import.save_data(result: result)
        saved_values1 = wolf_sensor.sensor_readings.order(:created_at).pluck(:calibrated_value)
        saved_values2 = wolf_sensor2.sensor_readings.order(:created_at).pluck(:calibrated_value)

        expect(saved_values1).to eq([10, 20, 30])
        expect(saved_values2).to eq([10, 20, 30])
      end
    end

    context 'given two sensor types for the same series' do
      let(:sensor_type1) do
        type = WolfWaagenApi::Import::SENSOR_TYPES.first
        create(:sensor_type, property: type[:property], unit: type[:unit])
      end

      let(:sensor_type2) do
        type = WolfWaagenApi::Import::SENSOR_TYPES.second
        create(:sensor_type, property: type[:property], unit: type[:unit])
      end

      let(:sensor1) do
        create(:sensor, sensor_type: sensor_type1, name: 'Sensor 1', report: report)
      end

      let(:sensor2) do
        create(:sensor, sensor_type: sensor_type2, name: 'Sensor 2', report: report)
      end

      before do
        sensor1
        sensor2
      end

      it 'creates readings for sensors of both types' do
        import.save_data(result: result)
        saved_values1 = sensor1.sensor_readings.order(:created_at).pluck(:calibrated_value)
        saved_values2 = sensor2.sensor_readings.order(:created_at).pluck(:calibrated_value)

        expect(saved_values1).to eq([10, 30, 30, 70]) # type for accumulated yield
        expect(saved_values2).to eq([10, 20, 30, 40]) # type for yield data only
      end
    end
  end

  describe '#save_series_data' do
    context 'given an accumulation interval' do
      subject { wolf_sensor.sensor_readings.order(:created_at).pluck(:calibrated_value) }

      context 'accumulates values' do
        before do
          import.save_series_data(
            series: result.series.second,
            sensor: wolf_sensor,
            interval: :daily
          )
        end

        it { is_expected.to eq([10, 30, 30, 70]) }
      end

      context 'after importing multiple times' do
        before do
          options = {
            series: result.series.second,
            sensor: wolf_sensor,
            interval: :daily
          }

          import.save_series_data(options)
          import.save_series_data(options)
        end

        it { is_expected.to eq([10, 30, 30, 70]) }
      end 

      context 'ignores points without a value' do
        before do
          import.save_series_data(
            series: result.series.third,
            sensor: wolf_sensor,
            interval: :daily
          )
        end

        it { is_expected.to eq([10, 10, 30]) }
      end
    end
  end

  describe '#accumulated_value' do
    let(:series) do
      result.series.second
    end

    context 'if no sensor readings exist' do
      it 'returns point value' do
        value = import.accumulated_value(
          sensor: wolf_sensor,
          interval: :daily,
          point: series.points.second # 2019-01-01 12:00
        )

        expect(value).to eq(20) # existing 0 + given 20
      end
    end

    context 'with existing sensor readings' do
      let(:existing_reading) do
        create(
          :sensor_reading,
          sensor: wolf_sensor,
          created_at: DateTime.new(2019, 1, 1, 6),
          calibrated_value: 20,
          uncalibrated_value: 20
        )
      end

      before { existing_reading }

      it 'ignores existing readings with the exact same date' do
        create(
          :sensor_reading,
          sensor: wolf_sensor,
          created_at: DateTime.new(2019, 1, 1),
          calibrated_value: 10,
          uncalibrated_value: 10
        )

        value = import.accumulated_value(
          sensor: wolf_sensor,
          interval: :daily,
          point: series.points.first
        )

        expect(value).to eq(10)
      end

      it 'returns sum of given point and latest value in given interval' do
        value = import.accumulated_value(
          sensor: wolf_sensor,
          interval: :daily,
          point: series.points.second # 2019-01-01 12:00
        )

        expect(value).to eq(40) # existing 20 + given 20
      end

      it 'considers sensor readings in the given interval only' do
        value = import.accumulated_value(
          sensor: wolf_sensor,
          interval: :daily,
          point: series.points.third # 2019-01-02 00:00
        )

        expect(value).to eq(30) # existing 0 + given 30
      end

      it 'considers sensor readings created before the given point only' do
        value = import.accumulated_value(
          sensor: wolf_sensor,
          interval: :daily,
          point: series.points.first # 2019-01-01 00:00
        )

        expect(value).to eq(10) # existing 0 + given 10
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
