require 'rails_helper'

RSpec.describe TextComponent, type: :model do
  describe '#heading' do
    context 'empty' do
      subject { build(:text_component, heading: '  ') }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#triggers' do
    let(:text_component) { create(:text_component) }
    subject { text_component.triggers }
    it { is_expected.to be_empty }
  end

  describe '#active?' do
    let(:text_component) { create(:text_component) }
    subject { text_component.active? }
    context 'triggers empty' do
      it { is_expected.to be true }

      context 'given one trigger' do
        context 'active trigger' do
          let(:text_component) { create(:text_component, triggers: [create(:trigger, :active)]) }
          it { is_expected.to be true }
        end

        context 'inactive trigger' do
          let(:text_component) { create(:text_component, triggers: [create(:trigger, :inactive)]) }
          it { is_expected.to be false }
        end
      end
      context 'given many triggers' do
        let(:text_component) { create(:text_component, triggers: triggers) }
        context'some are active, some are inactive' do
          let(:triggers) { [create(:trigger, :inactive), create(:trigger, :active)] }
          it { is_expected.to be false }
        end
        context'all active' do
          let(:triggers) { create_list(:trigger, 2, :active) }
          it { is_expected.to be true }
        end
      end
    end
  end
end
