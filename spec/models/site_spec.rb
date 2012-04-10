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

  describe "#to_csv" do
    it "should call compile_files_to_csv on the processor" do
      @processor = CopyProcess::Processor.new
      @processor.stub!(:compile_files_to_csv)
      CopyProcess::Processor.stub!(:new).and_return(@processor)
      @processor.should_receive(:compile_files_to_csv)
      Site.new.to_csv(false)
    end
  end

  describe "#compile_to_save" do
    before do
      simple_site
      @processor = CopyProcess::Processor.new
      @processor.stub!(:compile_files_to_element_types)
      CopyProcess::Processor.stub!(:new).and_return(@processor)
      @site.stub!(:destroy_all_element_types)
    end

    it "should destroy all existing element types" do
      @site.should_receive(:destroy_all_element_types)
      @site.compile_to_save({})
    end

    it "should call set_documents if params[:include] exists" do
      @site.stub!(:set_documents)
      @site.should_receive(:set_documents)
      @site.compile_to_save({ include: [1, 2] })
    end

    it "should call compile_files_to_element_types" do
      @processor.should_receive(:compile_files_to_element_types)
      @site.compile_to_save({ include: [1, 2] })
    end
  end
end