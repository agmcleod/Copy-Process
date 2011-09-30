
Given /^the following (.+) exist(?:|s):$/ do |model_name, table|
  model = get_model_from_string(model_name)
  table.hashes.each do |hash|
    prepare_and_save_model(model, hash)
  end
end

Given /^the following (.+) exist for the (.+) with (.+) "([^"]*)":$/ do |model_name, parent_model_name, parent_attribute, parent_value, table|
  model = get_model_from_string(model_name)
  parent = get_model_from_string(parent_model_name).send("find_by_#{parent_attribute}", parent_value)
  table.hashes.each do |hash|
    prepare_and_save_model(model, hash, parent)
  end
end

Given /^no (.+) have been created$/ do |model|
  get_model_from_string(model).destroy_all
end

Given /^the following subpages exist for "([^"]*)":$/ do |name, table|
  Given %Q{the following pages exist for the page with name "#{name}":}, table
end

def prepare_and_save_model(model, hash, parent = nil)
  if parent
    foreign_key = (model.name == parent.class.name) ? 'parent_id' : parent.class.name.foreign_key
    hash[foreign_key] = parent.id
  end
  m = model.new(hash)
  m.save
end

def get_model_from_string(s)
  s.parameterize('_').classify.constantize
end