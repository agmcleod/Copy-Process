Feature: Download elements as CSV
  In order to import content into PAGETorrent
  as a user, I want to download a CSV of the copy.
  
  Scenario: Elements already compiled
    Given I am on the homepage
    When I compile documents
    And I go to site page My Test
    And I follow "Export CSV"
    Then I should get a response with content-type "text/csv"