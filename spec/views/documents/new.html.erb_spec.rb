require 'spec_helper'

describe "documents/new.html.erb" do
  before(:each) do
    assign(:document, stub_model(Document,
      :content => "MyText"
    ).as_new_record)
  end

  it "renders new document form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => documents_path, :method => "post" do
      assert_select "textarea#document_content", :name => "document[content]"
    end
  end
end
