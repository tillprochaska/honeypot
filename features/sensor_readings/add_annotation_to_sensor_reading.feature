Feature: Add annotations to sensor readings
  As a journalist
  I want annotate a particular sensor reading
  To display a hint in the data visualization, e.g. if something extraordinary happened


	@javascript
  Scenario: Add annotations to a particular sensor reading
    Given there is a sensor live report
    And I am the journalist
    And we have these sensor readings for sensor 95 in our database:
      | Id    | Created at              | Calibrated value | Uncalibrated value | Release |
      | 24569 | 2017-07-18 14:09 +02:00 | 39.459           | 39.459             | final   |
      | 24557 | 2017-07-18 13:39 +02:00 | 39.248           | 39.248             | final   |
      | 24545 | 2017-07-18 13:09 +02:00 | 38.382           | 38.382             | final   |
      | 24527 | 2017-07-18 12:19 +02:00 | 45.008           | 45.008             | final   |
      | 24521 | 2017-07-18 12:09 +02:00 | 46.068           | 46.068             | final   |
    When I visit its sensor page
    And annotate sensor reading 24527 with "Sudden increase"
    Then the annotation was successfully saved to the database and I can see it on the page

  Scenario: Include annotations in response
    Given we have these sensor readings for sensor 95 in our database:
      | Id    | Created at              | Calibrated value | Uncalibrated value | Release | Annotation      |
      | 24569 | 2017-07-18 14:09 +02:00 | 39.459           | 39.459             | final   |                 |
      | 24557 | 2017-07-18 13:39 +02:00 | 39.248           | 39.248             | final   |                 |
      | 24545 | 2017-07-18 13:09 +02:00 | 38.382           | 38.382             | final   |                 |
      | 24527 | 2017-07-18 12:19 +02:00 | 45.008           | 45.008             | final   | Sudden increase |
      | 24521 | 2017-07-18 12:09 +02:00 | 46.068           | 46.068             | final   |                 |
    And I send and accept JSON
    When I send a GET request to "reports/1/sensors/95/sensor_readings"
    Then the JSON response should be:
    """
    [
        {
            "id": 24569,
            "created_at": "2017-07-18T14:09:00.000+02:00",
            "calibrated_value": 39.459,
            "uncalibrated_value": 39.459,
            "release": "final",
            "annotation": null
        },
        {
            "id": 24557,
            "created_at": "2017-07-18T13:39:00.000+02:00",
            "calibrated_value": 39.248,
            "uncalibrated_value": 39.248,
            "release": "final",
            "annotation": null
        },
        {
            "id": 24545,
            "created_at": "2017-07-18T13:09:00.000+02:00",
            "calibrated_value": 38.382,
            "uncalibrated_value": 38.382,
            "release": "final",
            "annotation": null
        },
        {
            "id": 24527,
            "created_at": "2017-07-18T12:19:00.000+02:00",
            "calibrated_value": 45.008,
            "uncalibrated_value": 45.008,
            "release": "final",
            "annotation": "Sudden increase"
        },
        {
            "id": 24521,
            "created_at": "2017-07-18T12:09:00.000+02:00",
            "calibrated_value": 46.068,
            "uncalibrated_value": 46.068,
            "release": "final",
            "annotation": null
        }
    ]
    """
