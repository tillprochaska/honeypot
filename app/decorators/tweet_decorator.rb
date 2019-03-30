# frozen_string_literal: true

require 'twitter'

class TweetDecorator
  HASHTAG = '#bienenlive'
  HOST = 'https://bienenlive.wdr.de'

  def initialize(diary_entry)
    @diary_entry = diary_entry
  end

  def tweet!
    client = Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
    end

    client.update(tweet_content)
  end

  def read_more_link
    report = @diary_entry.report
    return HOST if report.frontend_base_url.blank?

    "#{HOST}/#{report.frontend_base_url}/#{@diary_entry.id}"
  end

  def tweet_content
    call_to_action = "#{HASHTAG} - Mehr erfahren: #{read_more_link}"
    remaining_characters = 280 - call_to_action.length - 1 # 1 whitespace
    text = ActionController::Base.helpers.strip_tags(@diary_entry.main_part)
    text = ActionController::Base.helpers.truncate(text, length: remaining_characters, separator: '.')
    text = text.gsub(/\s+/, ' ').strip
    "#{text} #{call_to_action}"
  end
end
