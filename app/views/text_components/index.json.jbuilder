# frozen_string_literal: true

json.array! @text_components, partial: 'text_components/text_component', as: :text_component
