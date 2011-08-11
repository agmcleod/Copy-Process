Feature: Compile Documents and download CSV
  In order to download a formatted CSV
  As a user I want to be able to compile the document
  
  Scenario: Documents Exist
    Given I am on the homepage
    When I compile and export documents
    Then I should get a response with content-type "text/csv"