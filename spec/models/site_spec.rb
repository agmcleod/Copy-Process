require 'spec_helper'

describe Site do
  describe "#set_documents" do
    before do
      @site = Site.new
      d1 = Factory.build(:good_document)
      d1.id = 1
      d2 = Factory.build(:good_document)
      d2.id = 2
      @site.documents << d1
      @site.documents << d2
    end

    it "should return an array of 0 size" do
      @site.send("set_documents", {"3" => "1"}).size.should == 0
    end

    it "should return an array of 1 size" do
      @site.send("set_documents", {"2" => "1"}).size.should == 1
    end

    it "the first elements should be a document" do
      @site.send("set_documents", {"2" => "1"}).first.class.should == Document
    end
  end
end