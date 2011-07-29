require 'spec_helper'

describe "documents/index.html.erb" do
  before(:each) do
    assign(:documents, [
      stub_model(Document,
        :content => "MyText"
      ),
      stub_model(Document,
        :content => "MyText"
      )
    ])
  end

  it "renders a list of documents" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
