Feature: Compile Documents and download CSV
  In order to download a formatted CSV
  As a user I want to be able to compile the document
  
  Scenario: Documents Exist
    Given I am on the homepage
    When site "My Test" exists
    And site "My Test" has documents
    And I go to site page My Test
    And I press "Compile Documents"
    Then I should get a response with content-type "text/csv"