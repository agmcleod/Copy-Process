Feature: Search and replace
  As a user
  In order to improve the quality of the content being used
  I would like to be able to search and replace content, to quickly fix mistakes, and put in the tokens
  
  Scenario: Enters in an available search term
    Given I am on the homepage
    When I compile documents
    And I follow "Search/Replace"
    And I fill in "search" with "Recycling"
    And I check "case_sensitive"
    And I press "Search"
    Then I should see 4 ".etname" tags
    
  Scenario: Enters in an unavailable search term
    Given I am on the homepage
    When I compile documents
    And I follow "Search/Replace"
    And I fill in "search" with "sdfhjusehnf"
    And I press "Search"
    Then I should see "Content not found."