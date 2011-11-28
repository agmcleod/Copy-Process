When /^site "([^"]*)" exists$/ do |name|
  if Site.find_by_name(name).nil?
    Site.create(:name => name)
  end
end

When /^I copy and paste a document$/ do
  doc = Factory.build(:good_document)
  fill_in "document_content", :with => doc.content
end

When /^I copy and paste an invalid document$/ do
  doc = Factory.build(:bad_document)
  fill_in "document_content", :with => doc.content
end