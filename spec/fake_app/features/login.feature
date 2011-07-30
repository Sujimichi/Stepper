@users @user_sessions
Feature: Logging in to the site

  Scenario: A registered user enters correct login and password
    Given the registered user "test_user" with the password "foobar"
    And I am on the front-page
    When I sign in as "test_user" with "foobar"
    Then I should be logged in

  Scenario: A registered user enters incorrect password
    Given the registered user "test_user" with the password "foobar"
    And I am on the front-page
    When I sign in as "test_user" with "fibble"
    Then I should not be logged in
