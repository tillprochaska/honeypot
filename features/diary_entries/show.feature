@430
Feature: Generate sensorstory as JSON for frontend
  As a frontend designer
  I want the live sensorstory be generated as json (following the example of chatfuel channel)
  In order to easily integrate the sensorstory in my frontend.

  Background:
    Given we have these diary entries in our database:
      | Id | Moment           | release | Report id |
      | 1  | 2017-06-21 14:00 | final   | 1         |
    And there is a triggered text component with the following main part:
    """
    Manche checkens gleich, andere raffen es später
    Doch jeder weiss das Leben ist Metapher als Leder
    """
    And I send and accept JSON

  Scenario: Generate sensorstory on the fly and send as json
    When I send a GET request to "/reports/1/diary_entries/1"
    Then the JSON response should be:
    """
    {
      "id": 1,
      "moment": "2017-06-21T14:00:00.000+02:00",
      "release": "final",
      "heading": "MyString",
      "introduction": "<ul>\n<li>MyText</li>\n</ul>\n",
      "main_part": "<p>Manche checkens gleich, andere raffen es später\nDoch jeder weiss das Leben ist Metapher als Leder<span class='resi-thread'>\n</span>\n</p>\n",
      "closing": "MyText",
      "url": "http://example.org/reports/1/diary_entries/1.json"
    }
    """
