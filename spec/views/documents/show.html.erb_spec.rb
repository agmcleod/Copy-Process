require 'spec_helper'

describe "documents/show.html.erb" do
  before(:each) do
    @document = assign(:document, stub_model(Document,
      :content => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
