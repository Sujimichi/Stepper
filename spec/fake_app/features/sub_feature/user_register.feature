@overview
@users @organisations
Feature: Register a new User

  Scenario: An unregistered user can click register on the font-page
    Given I am on the front-page
    And I am not logged in
    And I click the "register" link
    Then I should be on the register page

  Scenario: A logged in user should not be able to access the register page
    Given I am logged in as "foo"
    When I go to the register page
    Then I should not be on the register page
    And I should be on the dashboard
    And the page should show flash errors
