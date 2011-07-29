Feature: Add Documents To Site
  In order to obtain the necessary CSV file
  As a user
  I want to be able to add documents
  
  Scenario: Valid document format
    Given I am on the homepage
    When site "My Test" exists
    And I follow "My Test"
    And I press "Add Document"
    When I copy and paste a document
    And I press "Create"
    Then I should see "Document was successfully created."