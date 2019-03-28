# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'chains/edit', type: :view do
  before(:each) do
    @chain = assign(:chain, Chain.create!(
                              actuator: nil,
                              function: 'activate',
                              hashtag: 'MyString'
                            ))
  end

  it 'renders the edit chain form' do
    render

    assert_select 'form[action=?][method=?]', chain_path(@chain), 'post' do
      assert_select 'select#chain_actuator_id[name=?]', 'chain[actuator_id]'

      assert_select 'select#chain_function[name=?]', 'chain[function]'

      assert_select 'input#chain_hashtag[name=?]', 'chain[hashtag]'
    end
  end
end
