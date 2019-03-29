# frozen_string_literal: true

namespace :twitter do
  desc 'Tweet latest diary entries'
  task tweet: :environment do
    Report.find_each do |report|
      diary_entry = report.diary_entries.final.last
      next unless diary_entry
      t = TweetDecorator.new(diary_entry)
      t.tweet!
    end
  end
end
