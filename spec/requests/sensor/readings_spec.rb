# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sensor::Reading, type: :request do
  let(:headers) do
    {
      'ACCEPT' => 'application/json',
      'Content-Type' => 'application/json'
    }
  end
  let(:report) { create(:report, id: 47) }
  let(:sensor) { create(:sensor, id: 11, report: report) }
  let(:url) { "/reports/#{report.id}/sensors/#{sensor.id}/sensor_readings" }
  let(:request) { post url, params: params.to_json, headers: headers }

  context 'sensor is calibrating' do
    let(:sensor) { create(:sensor, id: 123, calibrating: true) }

    let(:params) do
      {
        uncalibrated_value: 5.0
      }
    end

    it 'changes sensor calibration' do
      expect { request }.to change { sensor.reload; sensor.min_value }.to(5.0)
    end

    it 'does not create any sensor reading' do
      expect(Sensor::Reading.count).to eq 0
      expect { request }.not_to change { Sensor::Reading.count }
    end
  end
end
