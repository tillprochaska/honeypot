# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, './log/cron.log'

every 1.minutes do
  rake 'cache:delete'
end

# %w[00:10am 6:10am 9:10am 1:10pm 6:10pm].each do |time|
#   every :day, at: time do
#     rake 'archive'
#   end
# end

# every :hour, at: 5 do
#   rake 'wolf_waagen_api:fetch'
# end

# %w[09:10 14:10 19:10].each do |time|
#   every :day, at: time do
    # ["Königreich Köln (Gimnich)", 4]
#     rake 'twitter:tweet[4]'
#   end
end

# %w[09:40 14:40 19:40].each do |time|
#   every :day, at: time do
    # ["Königreich Lage (Strulik)", 2]
#     rake 'twitter:tweet[2]'
#  end
# end

# %w[10:10 15:10 20:10].each do |time|
#   every :day, at: time do
    # ["Königreich Witten (Marcel)", 3]
#     rake 'twitter:tweet[3]'
#   end
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
