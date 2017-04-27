class ChatfuelController < ApplicationController
  def show
    chatbot_channel = Channel.chatbot

    tc = Text::Sorter.sort(chatbot_channel.text_components, {}).first

    if tc
      text = Text::Renderer.new(text_component: tc).render(:main_part)

      qa = tc.question_answers

      #Test API Request: http://localhost:3000/chatfuel/1
      if qa
          sendJsonResponse(text, 1, qa.find(1).question)
      else
          sendJsonResponse(text)
      end

    else
     render json: {}, status: 404
    end
  end

  def showQuestionAndAnswer
      # request for qa for a specific text component
      # send answer as json response to chatfuel
      # if more questions and answers available, append button for next answer to json response

      chatbot_channel = Channel.chatbot

      tc = Text::Sorter.sort(chatbot_channel.text_components, {}).first

      if tc
          qaId = params[:id]

          if tc.question_answers.exists?(qaId)
              qa = tc.question_answers.find(qaId)

              if tc.question_answers.exists?(qaId.to_i + 1)
                  # send answer + button for next question
                  sendJsonResponse(qa.answer, qaId.to_i + 1, tc.question_answers.find(qaId.to_i + 1).question)
              else
                  # send only answer for this question
                  sendJsonResponse(qa.answer)
              end
          else
              render json: {}, status: 404
          end

      else
          render json: {}, status: 404
      end
  end

  def sendJsonResponse(text, qaId = 0, questionText = '')
      if qaId.to_i == 0
          @response = {
            messages: [
              { text: text.first(640)} # Messages for Facebook Messenger can only be 640 characters long. Source: https://developers.facebook.com/docs/messenger-platform/send-api-reference#request
            ]
          }
      else
          # send json response with text + qa button
          # todo: create url for next question from question id
          @response = {
              "messages": [
                  {
                    "attachment": {
                      "type": "template",
                      "payload": {
                        "template_type": "button",
                        "text": text.first(640),
                        "buttons": [
                          {
                            "type": "web_url",
                            "url": chatfuel_qa_url(params[:topic], qaId), #'test',  #generate url for next question
                            "title": questionText.first(640) #question
                          }
                        ]
                      }
                    }
                  }
                ]
          }
      end

      render json: @response
  end
end
