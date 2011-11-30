Feature: Add Documents To Site
  In order to obtain the necessary CSV file
  As a user
  I want to be able to add documents
  
  Scenario: Valid document format
    Given I am logged in
    When I am on the homepage
    When site "My Test" exists
    And I go to site page My Test
    And I press "add_document"    
    When I copy and paste a document
    And I press "Create Document"
    Then I should see "Document was successfully created."
    
  Scenario: Valid but already existing
    Given I am logged in
    When I am on the homepage
    When site "My Test" exists
    And I go to site page My Test
    And I press "add_document"    
    When I copy and paste a document
    And I press "Create Document"
    Then I should see "Document was successfully created."
    And I go to site page My Test
    And I press "add_document"    
    When I copy and paste a document
    And I press "Create Document"
    Then I should see "Content headers are not unique."
    
  Scenario: Invalid document format
    Given I am logged in
    When I am on the homepage
    When site "My Test" exists
    And I go to site page My Test
    And I press "add_document"    
    When I copy and paste an invalid document
    And I press "Create Document"
    Then I should see "Content Headers must be in valid format"