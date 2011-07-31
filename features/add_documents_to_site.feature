Feature: Add Documents To Site
  In order to obtain the necessary CSV file
  As a user
  I want to be able to add documents
  
  Scenario: Valid document format
    Given I am on the homepage
    When site "My Test" exists
    And I am on My Test site page
    And I press "add_document"    
    When I copy and paste a document
    And I press "Create Document"
    Then I should see "Document was successfully created."
    
    
  Scenario: Invalid document format
    Given I am on the homepage
    When site "My Test" exists
    And I am on My Test site page
    And I press "add_document"    
    When I copy and paste an invalid document
    And I press "Create Document"
    Then I should see "Contents must be in valid format"