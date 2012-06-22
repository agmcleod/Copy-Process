require 'csv'

When /^site "([^"]*)" has documents$/ do |name|
  site = Site.find_by_name(name)
  if site.documents.nil? || site.documents.size == 0
    doc = site.documents.build
    doc2 = site.documents.build
    version = Factory.build(:version)
    version2 = version
    version2.content = version.content.gsub('Variation 2', 'Variation: 3')
    
    doc.versions << version
    doc.active_version = version
    version.document = doc
    version.save
    
    doc2.versions << version2
    doc2.active_version = version2
    version2.document = doc2
    version2.save
    
    site.save
  end
end

When /^site "([^"]*)" has a french document$/ do |name|
  site = Site.find_by_name(name)
  if site.documents.nil? || site.documents.size == 0
    doc = site.documents.build
    doc2 = site.documents.build
    version = Factory.build(:french_version)
    version2 = version
    version2.content = version.content.gsub('Variation 1', 'Variation: 2')
    
    doc.versions << version
    doc.active_version = version
    version.document = doc
    version.save
    
    doc2.versions << version2
    doc2.active_version = version2
    version2.document = doc2
    version2.save
    
    site.save
  end
end

Then /^I should get a response with content-type "([^"]*)"$/ do |content_type|
  page.response_headers['Content-Type'].index(content_type).should_not == nil
end

Then /^column (\d+) row (\d+) should have a value$/ do |col, row|
  rows = CSV.parse(page.source)
  col = col.to_i - 1
  row = row.to_i - 1
  rows[row][col].should_not == nil
  rows[row][col].should_not == ""
end

Then /^column (\d+) row (\d+) should be "([^"]*)"$/ do |col, row, val|
  rows = CSV.parse(page.source)
  col = col.to_i - 1
  row = row.to_i - 1
  rows[row][col].should == val
end

Then /^column (\d+) row (\d+) should contain "([^"]*)"$/ do |col, row, val|
  rows = CSV.parse(page.source)
  col = col.to_i - 1
  row = row.to_i - 1
  rows[row][col].index(val).should_not == nil
end

When /^I compile documents$/ do
  steps %Q{
    When site "My Test" exists
    And site "My Test" has documents
    And I go to site page My Test
    And I press "Compile Documents"
  }
end
Then /^I should see (\d+) "([^"]*)" tags$/ do |amount, tag_name|
  page.find(:css, tag_name, :count=>amount)
end