require 'spec_helper'

module CopyProcess
  describe Processor do
    let(:output) { double('output').as_null_object }
    let(:processor) { Processor.new(output) }
    let(:input) { double('input').as_null_object }
    
    def valid_headers
      "/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/"
    end
    
    def content_to_write
      valid_headers + "\nsome text"
    end
    
    describe "#parse_each_file" do
      context "requires an example file" do
        before(:each) do
          @fn = 'testfile.txt'
          File.open(@fn, 'w+') { |f| f.write(content_to_write) }
          @files = []
        end
        
        after(:each) { File.delete(@fn) }
        it "should return an array with the size of one" do
          processor.parse_each_file(@fn, @files).size.should == 1
        end
      
        it "should return a object of type CopyFile" do
          processor.parse_each_file(@fn, @files).first.class.should == CopyFile
        end
      end
      
      it "should catch an ENOENT if there's an IO error, and respond with a msg" do
        fn = "somenotextexistantfile"
        output.should_receive(:puts).with("  Error => File not found: #{fn}")
        processor.parse_each_file(fn, [])
      end
    end
    
    describe "#set_file_names" do
      def file_names
        "sometext.txt;somefile.txt;anotherfile.txt"
      end
      it "should return an array of 3 names" do
        processor.set_file_names(file_names).size.should == 3
      end
      
      it "should contain the textfile named: somefile.txt" do
        processor.set_file_names(file_names).include?('somefile.txt').should be_true
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
  
    describe "#greeting" do
      it "should output a greeting" do
        output.should_receive(:puts).with("Please enter in the file path to the text document you wish to parse. \nSeparate multiple file names by using a semicolon.")
        processor.greeting(input)          
      end
    end
    
    describe "#initialize_file_objects" do
      it "should raise an error message if contents are nil" do
        lambda { processor.initialize_file_objects([], nil) }.should raise_error
      end
      
      it "should raise an error message if contents are empty" do
        lambda { processor.initialize_file_objects([], '') }.should raise_error
      end
      
      context "needs 3 files" do
        before(:all) do
          # create files first
          @contents = "somefile1.txt;somefile2.txt;somefile3.txt"
          @contents.split(';').each do |fn|
            File.open(fn, 'w+') { |f| f.write(content_to_write) }
          end
        end
        it "should return an array of 3" do
          processor.initialize_file_objects([], @contents).size.should == 3
        end
        
        it "should return a CopyFile object" do
          processor.initialize_file_objects([], @contents).first.class.should == CopyFile
        end
        
        after(:all) do
          @contents.split(';').each do |fn|
            File.delete(fn)
          end
        end
      end
    end
    
    describe "#add_missing_elements" do
      pending
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
    
    describe "#append_file_contents" do
      it "should return a string with the contents" do
        f = File.open('testfile_rspec.txt', 'w+')
        f.write("/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/\nHEADER: A header\nBODY: A body")
        contents = "/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/\nHEADER: A header\nBODY: A body"
        processor.append_file_contents('testfile_rspec.txt', contents).should == contents
        File.delete('testfile_rspec.txt')
      end
    end
  end
end