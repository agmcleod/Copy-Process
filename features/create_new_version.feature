Feature: Create a new version

  Scenario: Existing document
    Given I am logged in
    When site "My Test" exists
    And site "My Test" has documents
    And I go to site page My Test
    And I follow "Create new version"
    Then I should see "New version created and set as active. It can now be edited and reviewed."