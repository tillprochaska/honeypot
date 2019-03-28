# frozen_string_literal: true

Channel.create!([
                  { name: 'sensorstory', description: nil },
                  { name: 'chatbot', description: nil }
                ])
Report.create!([
                 { start_date: '2017-05-28', name: 'Kuh Bertha', video: nil, duration: nil },
                 { start_date: '2017-05-28', name: 'Industrie', video: nil, duration: nil },
                 { start_date: '2017-05-28', name: 'Bio', video: nil, duration: nil },
                 { start_date: '2017-05-28', name: 'Konventionell', video: nil, duration: nil }
               ])
