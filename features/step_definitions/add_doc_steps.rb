When /^site "([^"]*)" exists$/ do |name|
  if Site.find_by_name(name).nil?
    Site.create(:name => name)
  end
end

When /^I copy and paste a document$/ do
  fill_in "document_content", :with => Document.test_data
end

When /^I copy and paste an invalid document$/ do
  fill_in "document_content", :with => Document.bad_test_data
end