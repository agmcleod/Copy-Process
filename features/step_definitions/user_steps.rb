Given /^I am logged in$/ do
  email = 'example@example.com'
  password = 's3cure3x4mple'
  username = "example"
  
  steps %Q{
    Given the following user exists:
      | username    | email    | password    | password_confirmation |
      | #{username} | #{email} | #{password} | #{password}           |
    And I login as "#{email}" with the password "#{password}"
  }
end

Given /^I login as "([^\"]*)" with the password "([^\"]*)"$/ do |email, password|
  steps %Q{
    Given I am not logged in
    When I go to the login page
    And I fill in "user_email" with "#{email}"
    And I fill in "user_password" with "#{password}"
    And I press "Sign in"
  }
end

Given /^I am not logged in$/ do
  visit logout_path
end