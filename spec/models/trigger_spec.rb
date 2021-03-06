# frozen_string_literal: true

require 'rails_helper'

describe Trigger, type: :model do
  let(:trigger) { create :trigger }
  let(:sensor) { create(:sensor) }

  context 'given a sensor reading' do
    let(:diary_entry) { DiaryEntry.new(report: trigger.report, moment: Time.zone.now) }
    let(:trigger) { create(:trigger, :with_a_sensor_reading, params) }

    describe '#validity_period' do
      let(:params) { { validity_period: 3 } }

      it { trigger.active?(diary_entry) }

      context 'some hours later' do
        let(:future_diary_entry) do
          Timecop.travel(4.hours.from_now) do
            future_diary_entry = DiaryEntry.new(report: trigger.report, moment: Time.zone.now)
          end
        end

        it 'is no longer relevant' do
          Timecop.travel(4.hours.from_now) do
            expect(trigger).not_to be_active(future_diary_entry)
          end
        end

        it 'is still active for past diary entries' do
          Timecop.travel(4.hours.from_now) do
            expect(trigger).to be_active(diary_entry)
          end
        end
      end
    end
  end

  context 'without a report' do
    specify { expect(build(:trigger, report: nil)).not_to be_valid }
  end

  describe '#priority' do
    it 'defaults to :medium' do
      trigger = build(:trigger)
      expect(trigger.priority).to eq 'medium'
    end

    context 'missing' do
      subject { trigger }

      let(:trigger) { build(:trigger, priority: nil) }

      it { is_expected.not_to be_valid }
    end
  end

  describe '#events' do
    subject { trigger.events }

    let(:event) { create(:event, triggers: [trigger]) }

    before { event }

    it 'condition connects a trigger and a sensor' do
      is_expected.to include(event)
    end
  end

  describe '#sensors' do
    subject { trigger.sensors }

    before { create(:condition, trigger: trigger, sensor: sensor) }

    it 'condition connects a trigger and a sensor' do
      is_expected.to include(sensor)
    end
  end

  describe '#destroy' do
    describe '#conditions' do
      let(:conditions) do
        create_list(:condition, 3, trigger: trigger)
        create(:condition)
      end

      before { conditions }

      it 'get destroyed' do
        expect { trigger.destroy }.to change(Condition, :count).from(4).to(1)
      end
    end
  end

  describe '#active?' do
    subject { trigger.active?(diary_entry) }

    let(:diary_entry) { DiaryEntry.new }

    context 'without any conditions is considered active' do
      it { is_expected.to be_truthy }
    end

    context 'with connected sensor' do
      let(:condition) { create :condition, sensor: sensor, trigger: trigger, from: 1, to: 3 }

      before { condition }

      context 'and last calibrated value in range' do
        before { create :sensor_reading, sensor: sensor, calibrated_value: 2 }

        it { is_expected.to be_truthy }
      end

      context 'and last calibrated value outside range' do
        before { create :sensor_reading, sensor: sensor, calibrated_value: 0 }

        it { is_expected.to be_falsy }
      end

      context 'edge cases: a boundary of a condition is nil' do
        [{ from: nil, to: 23, value_in: 21, value_out: 24 },
         { from: 23, to: nil, value_in: 24, value_out: 21 }].each do |hash|
          context ":from=#{hash[:from].inspect} but :to=#{hash[:to].inspect}" do
            let(:condition) do
              create(:condition,
                     sensor: sensor,
                     trigger: trigger,
                     from: hash[:from],
                     to: hash[:to])
            end

            describe 'extends to infinity' do
              before { create :sensor_reading, sensor: sensor, calibrated_value: hash[:value_in] }

              it { is_expected.to be_truthy }
            end

            describe 'opposite boundary still required' do
              before { create :sensor_reading, sensor: sensor, calibrated_value: hash[:value_out] }

              it { is_expected.to be_falsy }
            end
          end
        end
      end

      context 'with sensor readings of different releases' do
        before do
          create :sensor_reading, sensor: sensor, calibrated_value: 0, release: :final
          create :sensor_reading, sensor: sensor, calibrated_value: 2, release: :debug
        end

        describe '#active? :final' do
          subject { trigger.active? DiaryEntry.new(release: :final) }

          it { is_expected.to be_falsy }
        end

        describe '#active? :debug' do
          subject { trigger.active? DiaryEntry.new(release: :debug) }

          it { is_expected.to be_truthy }
        end
      end
    end

    context 'given a diary entry' do
      let(:diary_entry) { create(:diary_entry) }

      context 'given events' do
        before { trigger.events << event }

        context 'event active now' do
          let(:event) { create(:event) }

          before { event.start }

          it { is_expected.to be_truthy }

          context 'but diary entry is at a time when the event was not yet active' do
            let(:diary_entry) { create(:diary_entry, moment: 1.week.ago) }

            it { is_expected.to be_falsy }
          end
        end
      end
    end
  end
end
