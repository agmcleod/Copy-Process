Feature: View Element Types
  As a user, I want to be able to view compiled element types determined when the documents are compiled
  for a particular site
  
  Scenario: Valid documents compiled
    Given I am on the homepage
    When I compile documents
    And I go to site page My Test
    And I follow "View Element Types"
    Then I should see "Listing Element Types"
    And I should see 6 "li" tags