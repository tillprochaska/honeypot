@453
Feature: Render markup in headings
  As an editor
  I want to be able to use markup for sensor values as well as events in
  the headings of text components in order to structure the diary entry

  Background:
    Given we have these diary entries in our database:
      | Id | Moment           | release |
      | 1  | 2017-06-21 14:00 | final   |
    And a humidity sensor with some sensor readings
    Given I have two short text commponents, that are active right now:
      | Heading                                     | Highest priority |
      | { value(1) }: That’s today’s humidity       | high             |
      | Let’s repeat it one more time: { value(1) } | low              |
    But there is also a medium prioritized, active component with a really long text

  Scenario: Render markup on the reports page
    When I visit the landing page
    Then I can see the main heading:
    """
    50.0 %: That’s today’s humidity
    """
    And I can see a subheading:
    """
    Let’s repeat it one more time: 50.0 %
    """

  Scenario: Render markup when requesting JSON via the API
    Given I send and accept JSON
    When I send a GET request to "/reports/1/diary_entries/1"
    Then the JSON response should be:
    """
    {
      "id": 1,
      "moment": "2017-06-21T14:00:00.000+02:00",
      "release": "final",
      "text_components": [
        {
          "closing": "MyText",
          "from_day": null,
          "heading": "50.0 %: That’s today’s humidity",
          "id": 1,
          "image_alt": null,
          "image_url": "/images/original/missing.png",
          "image_url_big": "/images/big/missing.png",
          "image_url_small": "/images/small/missing.png",
          "introduction": "MyText",
          "main_part": "MyText",
          "question_answers": [],
          "to_day": null,
          "url": "http://example.org/reports/1/text_components/1.json"
        },
        {
          "closing": "MyText",
          "from_day": null,
          "heading": "MyString",
          "id": 3,
          "image_alt": null,
          "image_url": "/images/original/missing.png",
          "image_url_big": "/images/big/missing.png",
          "image_url_small": "/images/small/missing.png",
          "introduction": "MyText",
          "main_part": "Blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaahhhh!",
          "question_answers": [],
          "to_day": null,
          "url": "http://example.org/reports/1/text_components/3.json"
        },
        {
          "closing": "MyText",
          "from_day": null,
          "heading": "Let’s repeat it one more time: 50.0 %",
          "id": 2,
          "image_alt": null,
          "image_url": "/images/original/missing.png",
          "image_url_big": "/images/big/missing.png",
          "image_url_small": "/images/small/missing.png",
          "introduction": "MyText",
          "main_part": "MyText",
          "question_answers": [],
          "to_day": null,
          "url": "http://example.org/reports/1/text_components/2.json"
        }
      ],
      "url": "http://example.org/reports/1/diary_entries/1.json"
    }
    """
