@453
Feature: Render markup for frontend
  As a frontend designer
  I want markup in diary entries to be replaced with e.g. values of sensor readings
  To incorporate sensor reading values in the report

  Background:
    Given we have these diary entries in our database:
      | Id | Moment           | release |
      | 1  | 2017-06-21 14:00 | final   |
    And a humidity sensor with some sensor readings
    And for this diary entry we have an active text component:
    """
    The humidity today is { value(1) }!
    """
    And this text component has these questions and answers:
      | Question                      | Answer        |
      | Could you say that once more? | { value(1) }  |
      | Really?!                      | Yep.          |
    And I send and accept JSON
  Scenario: Render sensor reading value
    When I send a GET request to "/reports/1/diary_entries/1"
    Then the JSON response should be:
    """
    {
      "id": 1,
      "moment": "2017-06-21T14:00:00.000+02:00",
      "release": "final",
      "heading": "MyString",
      "introduction": "<ul>\n<li>MyText</li>\n</ul>\n",
      "main_part": "<p>The humidity today is 50.0 %!<span class='resi-thread'>\n<button name=\"button\" type=\"submit\" class=\"resi-question btn btn-link\">(* Could you say that once more?)</button>\n<span class='resi-answer'>50.0 %</span>\n<button name=\"button\" type=\"submit\" class=\"resi-question btn btn-link\">(* Really?!)</button>\n<span class='resi-answer'>Yep.</span>\n</span>\n</p>\n",
      "closing": "MyText",
      "url": "http://example.org/reports/1/diary_entries/1.json"
    }
    """
