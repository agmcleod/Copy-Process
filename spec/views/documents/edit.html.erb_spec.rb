require 'spec_helper'

describe "documents/edit.html.erb" do
  before(:each) do
    @document = assign(:document, stub_model(Document,
      :content => "MyText"
    ))
  end

  it "renders the edit document form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => documents_path(@document), :method => "post" do
      assert_select "textarea#document_content", :name => "document[content]"
    end
  end
end
