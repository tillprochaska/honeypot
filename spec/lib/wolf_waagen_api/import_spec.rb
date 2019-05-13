# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

require 'rails_helper'

RSpec.describe WolfWaagenApi::Import do
  let(:report) do
    create(:report, hive_id: 'HIVE_ID', start_date: DateTime.new(2019, 1, 1))
  end

  let(:report_without_hive_id) do
    create(:report, hive_id: nil)
  end

  let(:other_report) do
    create(:report, hive_id: 'HIVE_ID2')
  end

  let(:wolf_sensor_type) do
    specified_type = WolfWaagenApi::Import::SENSOR_TYPES.second
    create(:sensor_type, property: specified_type[:property], unit: specified_type[:unit])
  end

  let(:wolf_sensor_type2) do
    specified_type = WolfWaagenApi::Import::SENSOR_TYPES.second
    create(:sensor_type, property: specified_type[:property], unit: specified_type[:unit])
  end

  let(:wolf_sensor) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Wolf Sensor 1', report: report)
  end

  let(:wolf_sensor2) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Wolf Sensor 2', report: report)
  end

  let(:wolf_sensor3) do
    create(:sensor, sensor_type: wolf_sensor_type2, name: 'Wolf Sensor 3', report: report)
  end

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

  let(:other_sensor_type) do
    create(:sensor_type, property: 'Other Sensor Type', unit: '')
  end

  let(:other_type_sensor) do
    create(:sensor, sensor_type: other_sensor_type, name: 'Other Sensor', report: report)
  end

  let(:other_report_sensor) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Other Report’s Wolf Sensor', report: other_report)
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
          # temperature (not accumulated)
          id: WolfWaagenApi::Import::SENSOR_TYPES.second[:series_id],
          values: [10, 20, 30]
        }, {
          # yield (accumulated daily)
          id: WolfWaagenApi::Import::SENSOR_TYPES.first[:series_id],
         # we have a daily accumulation interval and 12 hours frequency for new sensor readings
         # so below, two values go together
          values: [10, 20, 30, 40] 
        }]
      }
    )
  end

  describe '#initialize' do
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
      before do
        wolf_sensor
        other_type_sensor
      end

      it { is_expected.to eq([wolf_sensor]) }
    end

    context 'given sensor for other reports' do
      before do
        wolf_sensor
        other_report_sensor
      end

      it { is_expected.to eq([wolf_sensor]) }
    end

    context 'given no matching sensor' do
      before { other_sensor_type }

      it { is_expected.to eq([]) }
    end

    context 'given no sensor types match' do
      it { is_expected.to eq([]) }
    end
  end

  describe '#start_date' do
    subject { import.start_date }

    context 'given no sensor readings for one of two sensors' do
      before do
        wolf_sensor
        wolf_sensor2
        wolf_sensor_reading
      end

      it 'returns the report start date' do
        is_expected.to eq(DateTime.new(2019, 1, 1))
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
      subject { wolf_sensor.sensor_readings.pluck(:calibrated_value) }
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

        it { is_expected.to eq([10, 20, 30] )}
      end

    end

    context 'given two sensors of the same sensor type' do
      before do
        wolf_sensor
        wolf_sensor2
      end

      it 'creates sensor readings for both sensors' do
        import.save_data(result: result)
        saved_values1 = wolf_sensor.sensor_readings.pluck(:calibrated_value)
        saved_values2 = wolf_sensor2.sensor_readings.pluck(:calibrated_value)

        expect(saved_values1).to eq([10, 20, 30])
        expect(saved_values2).to eq([10, 20, 30])
      end
    end

    context 'given two sensor types for the same series' do
      before do
        wolf_sensor
        wolf_sensor3
      end

      it 'creates readings for sensors of both types' do
        import.save_data(result: result)
        saved_values1 = wolf_sensor.sensor_readings.pluck(:calibrated_value)
        saved_values3 = wolf_sensor3.sensor_readings.pluck(:calibrated_value)

        expect(saved_values1).to eq([10, 20, 30])
        expect(saved_values2).to eq([10, 20, 30])
      end
    end

  end

  describe '#save_series_data' do

    context 'given an accumulation interval' do
      context 'accumulates values' do
        subject { wolf_sensor.sensor_readings.pluck(:calibrated_value) }

        before do
          import.save_series_data(
            series: result.series.second,
            sensor: wolf_sensor,
            interval: :daily
          )
        end

        it { is_expected.to eq([10, 30, 30, 70]) }
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
