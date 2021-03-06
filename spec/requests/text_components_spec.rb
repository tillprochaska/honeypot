# frozen_string_literal: true

require 'rails_helper'
require 'support/shared_examples/report_namespaced_controller'

RSpec.describe 'TextComponents', type: :request do
  let(:report) { create(:report, id: 4711) }
  let(:user) { create(:user) }

  it_behaves_like 'a report/ namespaced controller', TextComponent

  before { sign_in user }

  describe 'GET /text_components' do
    it 'works! (now write some real specs)' do
      get report_text_components_path(report)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /text_components' do
    it 'renders validation errors' do
      post "/reports/#{report.id}/text_components", params: { text_component: { heading: nil } }
      parsed = Capybara.string(response.body)
      expect(parsed.first('.text-editor__field', text: 'Heading')).to have_text('can\'t be blank')
    end
  end

  describe 'PATCH /text_components/:id' do
    let(:tc) { create(:text_component) }

    describe '#timeframe' do
      before { tc }

      it 'updates #from_hour' do
        expect do
          patch "/reports/#{tc.report.id}/text_components/#{tc.id}", params: { text_component: { timeframe: '[6, 23]' } }
        end.to change { TextComponent.first.from_hour }.to(6)
      end

      it 'updates #to_hour' do
        expect do
          patch "/reports/#{tc.report.id}/text_components/#{tc.id}", params: { text_component: { timeframe: '[6, 23]' } }
        end.to change { TextComponent.first.to_hour }.to(23)
      end
    end

    it 'renders validation errors' do
      patch "/reports/1/text_components/#{tc.id}", params: { text_component: { heading: nil } }
      parsed = Capybara.string(response.body)
      expect(parsed.find('.text-editor__field', text: 'Heading')).to have_text('can\'t be blank')
    end
  end
end
