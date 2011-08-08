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