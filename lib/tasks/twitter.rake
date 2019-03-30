# frozen_string_literal: true

namespace :twitter do
  desc 'Tweet latest diary entries'
  task :tweet, [:report_id] => :environment do |_, args|
    report = Report.find(args[:report_id])
    diary_entry = DiaryEntry.new(report: report, release: :final)
    t = TweetDecorator.new(diary_entry)
    t.tweet!
  end
end
