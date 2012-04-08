require 'spec_helper'

def simple_site
  @site = Site.new
  d1 = Factory.build(:good_document)
  d1.id = 1
  d1.versions << Factory.build(:version)
  d2 = Factory.build(:good_document)
  d2.id = 2
  d2.versions << Factory.build(:version)
  @site.documents << d1
  @site.documents << d2
end

describe Site do
  describe "#set_documents" do
    before do
      simple_site
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

  describe "#prepare_documents" do
    before do
      simple_site
      @processor = CopyProcess::Processor.new
      @processor.stub!(:parse_each_document)
    end

    it "should return a CopyProcess::Processor" do
      CopyProcess::Processor.stub!(:new).and_return(@processor)
      @site.send("prepare_documents", []).class.should == CopyProcess::Processor
    end

    it "should call parse_each_document" do
      @processor.should_receive(:parse_each_document)
      CopyProcess::Processor.stub!(:new).and_return(@processor)
      @site.send("prepare_documents", [])
    end
  end
end