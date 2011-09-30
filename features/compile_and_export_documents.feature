Feature: Compile Documents and download CSV
  In order to download a formatted CSV
  As a user I want to be able to compile the document
  
  Scenario: Documents Exist
    Given I am logged in
    When I am on the homepage
    When I compile and export documents
    Then I should get a response with content-type "text/csv"
    
  Scenario: Parent folder structure enabled
    Given I am logged in
    When I am on the homepage
    When site "My Test" exists
    And site "My Test" has documents
    And I go to site page My Test
    And I check "parent_structure"
    And I press "Compile and Export Documents"
    Then column 4 row 3 should have a value
    And column 6 row 2 should be "<!-- -->"