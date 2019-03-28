# Bienen live
[![Build Status](https://travis-ci.org/tillprochaska/honeypot.svg?branch=master)](https://travis-ci.org/tillprochaska/honeypot)

## Installation

Make sure you have ruby version 2.3.4 installed on your system.

1. Clone the repository:
    ```
    git clone https://github.com/tillprochaska/honeypot
    ```

2. Install dependencies
    ```
    cd story.board
    bundle install
    ```

3. Run database migrations
    ```
    bin/rake db:create
    bin/rake db:migrate
    ```

4. Seed the database
    ```
    bin/rake db:seed
    ```

## Usage

Start the app with:
  ```
  bin/rails server
  ```

And point your browser to your [running instance](http://localhost:3000/).

## Demo
[Bienen live](https://bienenle.uber.space/).

## Domain Model

![Entity Relationship Diagram for StoryBoard app](erd.png)

## Test

We use rspec for unit and functional testing and cucumber for integration testing. You can run all the tests with:

  ```
  bin/rake
  ```

Or selectively
  ```
  bin/rspec spec/path/to/your/favourite/unit/test_spec.rb
  bin/cucumber features/path/to/your/acceptance/test.feature
  ```
## Documentation

We are [cucumber evangelists](https://cucumber.io/). See our executable, up-to-date documentation in the [features folder](/features).

## Contribute

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Run the tests: `bin/rake`
5. Push to the branch: `git push origin my-new-feature`
6. Submit a pull request :heart:





