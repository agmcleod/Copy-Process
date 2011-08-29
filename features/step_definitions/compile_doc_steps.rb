When /^site "([^"]*)" has documents$/ do |name|
  site = Site.find_by_name(name)
  if site.documents.nil? || site.documents.size == 0
    d = Document.new(content: Document.test_data)
    d2 = Document.new(content: Document.test_data.gsub('Variation: 2', 'Variation: 3'))
    d.save
    d2.save
    site.documents << d
    site.documents << d2
    site.save
  end
end

Then /^I should get a response with content-type "([^"]*)"$/ do |content_type|
  page.response_headers['Content-Type'].index(content_type).should_not == nil
end

When /^I compile documents$/ do
  steps %Q{
    When site "My Test" exists
    And site "My Test" has documents
    And I go to site page My Test
    And I press "Compile Documents"
  }
end

When /^I compile and export documents$/ do
  steps %Q{
    When site "My Test" exists
    And site "My Test" has documents
    And I go to site page My Test
    And I press "Compile and Export Documents"
  }
end

Then /^I should see (\d+) "([^"]*)" tags$/ do |amount, tag_name|
  page.find(:css, tag_name, :count=>amount)
end