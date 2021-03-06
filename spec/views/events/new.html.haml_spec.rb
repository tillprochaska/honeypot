# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events/new', type: :view do
  before do
    assign(:event, build(:event))
  end

  it 'renders new event form' do
    render

    assert_select 'form[action=?][method=?]', events_path, 'post' do
    end
  end
end
