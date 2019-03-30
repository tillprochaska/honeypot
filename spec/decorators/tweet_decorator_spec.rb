# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TweetDecorator do
  let(:decorator) { described_class.new(diary_entry) }
  let(:report) { create(:report, frontend_base_url: 'https://bienenlive.wdr.de/bienenkoenigin/mein-tagebuch') }
  let(:diary_entry) { create(:diary_entry, id: 4711, report: report) }

  before { stub_const('TweetDecorator::READ_MORE_VARIATIONS', ['Mehr erfahren']) }

  describe '#tweet_content' do
    subject { decorator.tweet_content }

    it { is_expected.to include('#bienenlive') }

    it { is_expected.to include('https://bienenlive.wdr.de/bienenkoenigin/mein-tagebuch/4711') }

    context 'report frontend_base_url blank' do
      let(:report) { build(:report, frontend_base_url: '   ') }

      before { report.save(validate: false) }

      it { is_expected.to include('https://bienenlive.wdr.de ') }
    end

    context 'with a text component' do
      let(:main_part) { 'Must be included in the tweet' }
      let(:intro) { '' }
      let(:components) { create_list(:text_component, 1, introduction: intro, main_part: main_part) }

      before { report.text_components << components }

      it { is_expected.to include('Must be included in the tweet') }
      it 'removes markup' do
        is_expected.not_to include('<p>')
      end

      context 'given intro' do
        let(:intro) { 'Your majesty queen maja is speaking:' }

        it { is_expected.to include('Your majesty queen maja is speaking:') }
      end

      context 'excessively long texts' do
        let(:main_part) { 'bla bla bla ' * 300 }

        describe 'length' do
          subject { decorator.tweet_content.length }

          it { is_expected.to be <= 280 }
        end

        context 'not a single sentence' do
          it 'cuts the text with a dot (edge case)' do
            is_expected.to include('bla bla . Mehr erfahren: ')
          end
        end

        describe 'containing sentences' do
          let(:main_part) { 'bla bla bla end.' * 300 }

          it 'cuts at sentences' do
            is_expected.to include('bla bla end. Mehr erfahren: ')
          end
        end
      end
    end
  end
end
