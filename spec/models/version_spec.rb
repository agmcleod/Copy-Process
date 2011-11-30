require 'spec_helper'

describe Version do
  describe "#content_is_in_valid_format" do
    before do
      @site = Site.create!(name: "test")
      @document = Document.new
      @document.site_id = @site.id
      @version = Factory.build(:version)
      @document.versions << @version
      @document.active_version = @version
      @version.document = @document
    end
    
    it "version should be valid, since the headers are unique to the document" do
      @version.valid?.should be_true
    end
    
    it "document parent should be valid, since the headers are unique to the document" do
      @document.valid?.should be_true
    end
  end
end
