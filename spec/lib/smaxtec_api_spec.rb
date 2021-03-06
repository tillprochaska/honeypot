# frozen_string_literal: true

require 'rails_helper'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    match_requests_on: [:method,
                        VCR.request_matchers.uri_without_param(:from_date, :to_date, :email, :password)]
  }
end

RSpec.describe SmaxtecApi do
  let(:smaxtec_api) { described_class.new }
  let(:sensor_type) { create(:sensor_type, property: 'Temperature', unit: '°C') }
  let(:sensor) { create(:sensor, name: 'Kuh Berta Temperature Test Sensor', sensor_type: sensor_type, animal_id: '5722099ea80a5f54c631513d') }

  describe '.last_smaxtec_sensor_reading' do
    subject do
      VCR.use_cassette('smaxtec_api', record: :once) do
        smaxtec_api.last_smaxtec_sensor_reading(sensor)
      end
    end

    it { is_expected.to be_a Sensor::Reading }
  end

  describe '.update_sensor_readings' do
    it 'updates the sensor readings from the Smaxtec API and integrate them to the system' do
      VCR.use_cassette('smaxtec_api', record: :once) do
        sensor # create
        # 72 new readings -> one reading for every 10 minutes, for 12 hours that's 72 readings
        expect { smaxtec_api.update_sensor_readings }.to change { Sensor::Reading.count }.from(0).to(72)
      end
    end
  end

  describe '.update_sensor_readings' do
    it 'does not create a sensor reading if the sensor reading for the specific sensor type already exists' do
      sensor # create
      VCR.use_cassette('smaxtec_api', record: :once) do
        expect { smaxtec_api.update_sensor_readings }.to change { Sensor::Reading.count }.from(0).to(72)
      end

      VCR.use_cassette('smaxtec_api', record: :once) do
        expect { smaxtec_api.update_sensor_readings }.not_to change { Sensor::Reading.count }
      end
    end
  end

  describe '.update_events' do
    let(:sensor_type) { create(:sensor_type, property: 'Event: Temperature increase', unit: '0-1') }
    let(:sensor) { create(:sensor, name: 'Kuh Berta Event: Temperature increase', sensor_type: sensor_type, animal_id: '5722099ea80a5f54c631513d') }

    it 'updates events and write them to the corresponding sensor, but not create the same event twice' do
      sensor # create
      VCR.use_cassette('smaxtec_api', record: :once) do
        expect { smaxtec_api.update_events }.to change { Sensor::Reading.count }.from(0).to(3)
      end

      VCR.use_cassette('smaxtec_api', record: :once) do
        expect { smaxtec_api.update_events }.not_to change { Sensor::Reading.count }
      end
    end
  end

  describe '.update_device_readings' do
    let(:sensor_type) { create(:sensor_type, property: 'Temperature', unit: '°C') }
    let(:sensor) { create(:sensor, name: 'Test Climate Stations', sensor_type: sensor_type, device_id: '0600000600') }

    it 'updates the device reading and write them to the corresponding sensor, but not create the same device reading twice' do
      sensor # create
      VCR.use_cassette('smaxtec_api', record: :once) do
        expect { smaxtec_api.update_device_readings }.to change { Sensor::Reading.count }.from(0).to(72)
      end

      VCR.use_cassette('smaxtec_api', record: :once) do
        expect { smaxtec_api.update_device_readings }.not_to change { Sensor::Reading.count }
      end
    end
  end
end
