# frozen_string_literal: true

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
    specified_type = WolfWaagenApi::Import::SENSOR_TYPES.first
    create(:sensor_type, property: specified_type[:property], unit: specified_type[:unit])
  end

  let(:wolf_sensor) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Wolf Sensor 1', report: report)
  end

  let(:wolf_sensor2) do
    create(:sensor, sensor_type: wolf_sensor_type, name: 'Wolf Sensor 2', report: report)
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

      it { is_expected.to eq([ wolf_sensor ]) }
    end

    context 'given sensor for other reports' do
      before do
        wolf_sensor
        other_report_sensor
      end

      it { is_expected.to eq([ wolf_sensor ]) }
    end


    context 'given no matching sensor' do
      before { other_sensor_type }

      it { is_expected.to eq([]) }
    end

    context 'given no sensor types match' do
      it { is_expected.to eq([]) }
    end
  end

  describe '#api_sensors_by_series_id' do
    subject do
      specified_type = WolfWaagenApi::Import::SENSOR_TYPES.first
      import.api_sensors_by_series_id(series_id: specified_type[:series_id])
    end

    context 'if no sensor type matches' do
      before { other_type_sensor }
      it { is_expected.to eq([]) }
    end

    context 'if no sensor matches' do
      before { wolf_sensor_type }
      it { is_expected.to eq([]) }
    end
  end

  describe '#start_date' do

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

  describe '#save_series_points' do
    let(:request) do
      WolfWaagenApi::Request.new(
        hive_id: 'HIVE_ID',
        start_date: DateTime.new(2019, 1, 1, 0, 0),
        end_date: DateTime.new(2019, 1, 2, 0, 0)
      )
    end

    let(:result) do
      WolfWaagenApi::Result.new(
        request: request,
        data: {
          pointStart: 1546300800000, # 2019-01-01 00:00:00
          pointInterval: 60 * 60 * 1000,
          series: [{
            id: WolfWaagenApi::Import::SENSOR_TYPES.first[:series_id],
            values: [10, 20, 30]
          }]
        }
      )
    end

    context 'given a Wolf Waagen sensor' do
      before { wolf_sensor }

      subject { wolf_sensor.sensor_readings.pluck(:calibrated_value) }

      context 'creates sensor readings for that sensor' do
        before { import.save_series_points(series: result.series.first) }
        it { is_expected.to eq([10, 20, 30]) }
      end

      context 'does not create duplicate sensor readings' do
        before do
          import.save_series_points(series: result.series.first)
          import.save_series_points(series: result.series.first)
        end
        
        it { is_expected.to eq([10, 20, 30]) }
      end
    end

    context 'given two Wolf Waagen sensors' do
      before do
        wolf_sensor
        wolf_sensor2
      end

      it 'creates sensor readings for both sensors' do
        import.save_series_points(series: result.series.first)
        saved_values1 = wolf_sensor.sensor_readings.pluck(:calibrated_value)
        saved_values2 = wolf_sensor2.sensor_readings.pluck(:calibrated_value)

        expect(saved_values1).to eq([10, 20, 30])
        expect(saved_values2).to eq([10, 20, 30])
      end
    end
  end
end
