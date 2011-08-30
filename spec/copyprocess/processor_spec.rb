require 'spec_helper'

module CopyProcess
  describe Processor do
    let(:output) { double('output').as_null_object }
    let(:input) { double('input').as_null_object }
    let(:processor) { Processor.new(output, input) }
    
    def valid_headers
      "/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/"
    end
    
    def content_to_write
      valid_headers + "\nsome text"
    end
    
    def create_test_files
      File.open('recycling1.txt', 'w+') do |f|
        txt = 
        "/*\n" +
        "Type: Recycling\n" +
        "Layer: State\n" +
        "Variation: 1\n" +
        "*/\n" +
        "HEADER: Recycling header.\n" +
        "BODY: Recycling sentence* one. A second sentence about\n" +
        "recycling. A third sentence about recycling.\n" +
        "CTA: A call to action\n" +
        "BODY: Recycling sentence* one. A second sentence about\n" +
        "recycling. A third sentence about recycling. A rhetorical question about\n" +
        "recycling?\n" +
        "FOOTER: Some footer\n" +
        "CTA2: A second call to action\n"
        f.write(txt)
      end
      File.open('recycling2.txt', 'w+') do |f|
        txt =
        "/*\n" +
        "Type: Recycling\n" +
        "Layer: State\n" +
        "Variation: 2\n" +
        "*/\n" +
        "HEADER: A second recycling header.\n" +
        "BODY: Recycling sentence one, again. A second sentence about\n" +
        "recycling, i think. A third sentence about recycling. A fouth sentence about \n" +
        "recycling.\n" +
        "CTA: A call to action - important.\n" +
        "BODY: Recycling sentence* onesise. A second sentence about\n" +
        "recycling. A third sentence about recycling?* A follow up sentence\n" +
        "FOOTER: Some sort of footer\n" +
        "CTA2: A second call to action\n"
        f.write(txt)
      end
      File.open('garbage1.txt', 'w+') do |f|
        txt =
        "/*\n" +
        "Type: Garbage Pickup\n" +
        "Layer: State\n" +
        "Variation: 1\n" +
        "*/\n" +
        "HEADER: A garbage pickup header.\n" +
        "BODY: garbage sentence one. A second sentence about\n" +
        "garbage, i think. A third sentence about picking up garbage. A fouth sentence about \n" +
        "it. A fifth sentence\n" +
        "CTA: A call to action - important (garbage).\n" +
        "BODY: Garbage sentence onesise. A second sentence about\n" +
        "garbage. A third sentence about garbage?* A follow up sentence\n" +
        "FOOTER: Some sort of footer - garbage related\n" +
        "CTA2: A second call to action\n"
        f.write(txt)          
      end
    end
    
    describe "#parse_each_document" do
      context "requires an example file" do
        before(:each) do
          @fn = 'testfile.txt'
          File.open(@fn, 'w+') { |f| f.write(content_to_write) }
          @files = []
        end
        
        after(:each) { File.delete(@fn) }
        
        it "should return an array with the size of one" do
          processor.parse_each_document(content_to_write, @files).size.should == 1
        end
      
        it "should return a object of type CopyFile" do
          processor.parse_each_document(content_to_write, @files).first.class.should == CopyFile
        end
      end
    end
    
    describe "#append_file_if_valid" do
      it "should raise an error if headers are false" do
        lambda { processor.append_file_if_valid('', false, [], 'somefilename') }.should raise_error
      end
      
      it "should return an array of one size" do
        processor.append_file_if_valid(content_to_write, valid_headers, [], 'somefilename').size.should == 1
      end
    end
    
    
    describe "#add_missing_elements" do
      it "should return an empty array" do
        keywords = ['lawncare', 'outdoor pestcontrol']
        types = ['national', 'state', 'city']
        tk = ["national+lawncare", "national+outdoor pestcontrol", 
          "state+lawncare", "state+outdoor pestcontrol",
          "city+lawncare", "city+outdoor pestcontrol"]
        processor.add_missing_elements([], keywords, types, tk).size.should == 0
      end
      
      it "should return an array of 1" do
        keywords = ['lawncare', 'outdoor pestcontrol']
        types = ['national', 'state', 'city']
        tk = ["national+lawncare", "national+outdoor pestcontrol", 
          "state+lawncare", "state+outdoor pestcontrol",
          "city+lawncare"]
        processor.add_missing_elements([], keywords, types, tk).size.should == 1
      end
      
      it "should return a string containing city+outdoor pestcontrol" do
        keywords = ['lawncare', 'outdoor pestcontrol']
        types = ['national', 'state', 'city']
        tk = ["national+lawncare", "national+outdoor pestcontrol", 
          "state+lawncare", "state+outdoor pestcontrol",
          "city+lawncare"]
        processor.add_missing_elements([], keywords, types, tk).first.should == "city,<!-- empty -->,empty for: outdoor pestcontrol"
      end
    end
    
    describe "#contains_valid_headers" do
      it "should return false if empty" do
        processor.contains_valid_headers('').should == false
      end
      context "Contains header names on one line but no values" do
        it "should return false" do
          processor.contains_valid_headers('/* Type: Layer: Variation */').should_not be_true
        end
      end
      context "Contains valid header names & format, no values" do
        it "should return false" do
          processor.contains_valid_headers("/*\nType: \nLayer: \nVariation \n*/").should_not be_true
        end
      end

      context "Contains valid header names, format and values" do
        it "should return true" do
          processor.contains_valid_headers(valid_headers).should be_true
        end
      end
    end
    
    describe "#retrieve_content_rows" do
      
      before(:all) do
        create_test_files
        File.open('testfile_rspec.txt', 'w+')  do |f|
          f.write("/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/\nHEADER: A header\nBODY: A body")
        end
      end
      
      before(:each) do
        @files = []
        %w{recycling1.txt recycling2.txt garbage1.txt}.each do |fn|
          d = Document.new(content: IO.read(fn))
          processor.parse_each_document(d.content, @files)
        end
      end
      
      it "should return 37 rows/sentences. 36 regular, 1 empty" do
        processor.retrieve_content_rows(@files).size.should == 37
      end
      
      it "should return 2 rows" do
        t = []
        processor.parse_each_document(IO.read('testfile_rspec.txt'), t)
        processor.retrieve_content_rows(t).size.should == 2
      end
      
      after(:all) do
        File.delete('recycling1.txt')
        File.delete('recycling2.txt')
        File.delete('garbage1.txt')
        File.delete('testfile_rspec.txt')
      end
    end
    
    describe "#compile_files_to_element_types"  do
      pending
    end
    
    describe "#compile_files_to_csv" do
      before(:all) do
        create_test_files
        DatabaseCleaner.strategy = :truncation
        DatabaseCleaner.clean_with(:truncation)
      end
      
      before(:each) do
        DatabaseCleaner.start
        @files = []
        @site = Site.new(name: 'somesite')
        %w{recycling1.txt recycling2.txt garbage1.txt}.each do |fn|
          @site.documents.build(content: IO.read(fn))
        end
        @site.save!
      end
      
      it "should return a non empty string" do
        @site.compile_to_save
        processor.compile_files_to_csv(@site).empty?.should be_false
      end
      
      it "should return proper csv headers" do
        @site.compile_to_save
        processor.compile_files_to_csv(@site).split("\n")[0].should == "ParentTypeID,TypeID,ElementID,ParentTypeName,TypeName,Content,Notes"
      end
      
      it "should return a string of 38 lines - 37 content, 1 header row" do
        @site.compile_to_save
        processor.compile_files_to_csv(@site).split("\n").size.should == 38
      end
      
      after(:each) do
        DatabaseCleaner.clean
      end
      
      after(:all) do
        File.delete('recycling1.txt')
        File.delete('recycling2.txt')
        File.delete('garbage1.txt')
        File.delete('testfile_rspec.txt')
      end
    end
  end
end