# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, './log/cron.log'

%w[09:00 14:00 19:00].each do |time|
  every :day, at: time do
    # ["Königreich Köln (Gimnich)", 4]
    rake 'twitter:tweet[4]'
  end
end

%w[09:30 14:30 19:30].each do |time|
  every :day, at: time do
    # ["Königreich Lage (Strulik)", 2]
    rake 'twitter:tweet[2]'
  end
end

%w[10:00 15:00 20:00].each do |time|
  every :day, at: time do
    # ["Königreich Witten (Marcel)", 3]
    rake 'twitter:tweet[3]'
  end
end

every 1.minutes do
  rake 'cache:delete'
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
