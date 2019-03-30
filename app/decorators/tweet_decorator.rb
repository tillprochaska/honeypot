# frozen_string_literal: true

require 'twitter'

class TweetDecorator
  HASHTAG = '#bienenlive'
  READ_MORE_VARIATIONS = [
    'Mehr erfahren',
    'Weiterlesen',
    'Rein ins Gesumm',
    'Mehr aus dem Volk',
    'Mehr von uns Königinnen',
    'Hier steht, was noch passiert',
    'Folge mir in mein Königreich',
    'Mein Leben als Königin',
    'Mehr von mir und meinem Bienenvolk',
    'Lies meinen ganzen Bericht',
    'Mehr als Honig'
  ].freeze
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

    "#{report.frontend_base_url}/#{@diary_entry.id}"
  end

  def tweet_content
    read_more = READ_MORE_VARIATIONS.sample
    call_to_action = "#{HASHTAG} - #{read_more}: #{read_more_link}"
    remaining_characters = 280 - call_to_action.length - 1 # 1 whitespace
    text = ActionController::Base.helpers.strip_tags(@diary_entry.main_part)
    text = ActionController::Base.helpers.truncate(text, length: remaining_characters, separator: '.', omission: '.')
    text = text.gsub(/\s+/, ' ').strip
    "#{text} #{call_to_action}"
  end
end
