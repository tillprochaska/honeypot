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
      "heading": "50.0 %: That’s today’s humidity",
      "introduction": "<ul>\n<li>MyText</li>\n<li>MyText</li>\n<li>MyText</li>\n</ul>\n",
      "main_part": "<p>MyText<span class='resi-thread'>\n</span>\n Blaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaahhhh!<span class='resi-thread'>\n</span>\n</p>\n<h4 class='sub-heading'>Let’s repeat it one more time: 50.0 %</h4>\n<p>MyText<span class='resi-thread'>\n</span>\n</p>\n",
      "closing": "MyText MyText MyText",
      "url": "http://example.org/reports/1/diary_entries/1.json"
    }
    """
