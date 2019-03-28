# frozen_string_literal: true

class CreateDefaultChannels < ActiveRecord::Migration[5.0]
  class Channel < ActiveRecord::Base
    belongs_to :report
  end

  class Report < ActiveRecord::Base
  end

  def change
    # make sure at least one report is there
    Report.create!(name: 'Kuh Bertha', start_date: Time.now) unless Report.first

    # for every report, create default channels
    Report.find_each do |report|
      %w[sensorstory chatbot].each do |channel_name|
        Channel.find_or_create_by(name: channel_name, report: report)
      end
    end
  end
end
