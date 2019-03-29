# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, './log/cron.log'

%w[00:05am 6:05am 9:05am 1:05pm 6:05pm].each do |time|
  every :day, at: time do
    rake 'twitter:tweet'
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
