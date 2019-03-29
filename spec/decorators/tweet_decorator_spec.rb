# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TweetDecorator do
  let(:decorator) { described_class.new(diary_entry) }
  let(:report) { create(:report, frontend_base_url: 'bienenkoenigin' ) }
  let(:diary_entry) { create(:diary_entry, id: 4711, report: report) }

  describe '#tweet_content' do
    subject { decorator.tweet_content }

    it { is_expected.to include('#bienenlive') }

    it { is_expected.to include('https://bienenlive.wdr.de/bienenkoenigin/mein-tagebuch/4711') }

    context 'report frontend_base_url blank' do
      let(:report) { build(:report, frontend_base_url: '   ') }
      before { report.save(validate: false) }
      it { is_expected.to end_with('https://bienenlive.wdr.de') }
    end


    context 'with a text component' do
      let(:main_part) { 'Must be included in the tweet' }
      let(:components) { create_list(:text_component, 1, main_part: main_part) }

      before { report.text_components << components }

      it { is_expected.to include("Must be included in the tweet") }

      describe 'length' do
        subject { decorator.tweet_content.length }
        it { is_expected.to be <= 280 }
      end
    end
  end
end
