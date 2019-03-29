# frozen_string_literal: true

namespace :twitter do
  desc 'Tweet latest diary entries'
  task tweet: :environment do
    Report.find_each do |report|
      diary_entry = DiaryEntry.new(report: report, release: :final)
      t = TweetDecorator.new(diary_entry)
      t.tweet!
    end
  end
end
