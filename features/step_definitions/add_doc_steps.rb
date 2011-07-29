When /^site "([^"]*)" exists$/ do |name|
  if Site.find_by_name(name).nil?
    Site.create(name: name)
  end
end

When /^I copy and paste a document$/ do
  
end