Feature: Search and replace
  As a user
  In order to improve the quality of the content being used
  I would like to be able to search and replace content, to quickly fix mistakes, and put in the tokens
  
  Scenario: Enters in an available search term
    Given I am logged in
    When I am on the homepage
    When I compile documents
    And I follow "Search/Replace"
    And I fill in "search" with "Recycling"
    And I check "case_sensitive"
    And I press "Search"
    Then I should see 4 ".etname" tags
    
  Scenario: Enters in an unavailable search term
    Given I am logged in
    When I am on the homepage
    When I compile documents
    And I follow "Search/Replace"
    And I fill in "search" with "sdfhjusehnf"
    And I press "Search"
    Then I should see "Content not found."
    
  Scenario: Enters in an available search term and a replace term, case insensive
    Given I am logged in
    When I am on the homepage
    When I compile documents
    And I follow "Search/Replace"
    And I fill in "search" with "Recycling"
    And I fill in "replace" with "Fishing"
    And I press "Search"
    Then I should see "Fishing"
    And I should not see "Recycling"
    And I should not see "recyling"
    
  Scenario: Enters in an available search term and a replace term, case sensitive
    Given I am logged in
    When I am on the homepage
    When I compile documents
    And I follow "Search/Replace"
    And I fill in "search" with "Recycling"
    And I fill in "replace" with "Fishing"
    And I check "case_sensitive"
    And I press "Search"
    Then I should see "Fishing"
    And I should see "recycling"
    And I should not see "Recycling"