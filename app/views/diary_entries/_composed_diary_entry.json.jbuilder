# frozen_string_literal: true

json.extract! diary_entry, :id, :moment, :release, :heading, :introduction, :main_part, :closing
json.url report_diary_entry_url(@report, diary_entry, format: :json)
