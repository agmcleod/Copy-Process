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
        lambda { processor.initialize_file_objects(nil) }.should raise_error
      end
      
      it "should raise an error message if contents are empty" do
        lambda { processor.initialize_file_objects('') }.should raise_error
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
          processor.initialize_file_objects(@contents).size.should == 3
        end
        
        it "should return a CopyFile object" do
          processor.initialize_file_objects(@contents).first.class.should == CopyFile
        end
        
        after(:all) do
          @contents.split(';').each do |fn|
            File.delete(fn)
          end
        end
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
    
    describe "#get_file_contents" do
      before(:each) do
        @c = "/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/\nHEADER: A header\nBODY: A body"
        File.open('testfile_rspec.txt', 'w+') { |f| f.write(@c) }
      end
      it "should return a string with the contents" do
        processor.get_file_contents('testfile_rspec.txt').should == @c
      end
      after(:each) { File.delete('testfile_rspec.txt') }
    end
    
    describe "#retrieve_content_rows" do
      
      before(:all) do
        create_test_files
        File.open('testfile_rspec.txt', 'w+')  do |f|
          f.write("/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/\nHEADER: A header\nBODY: A body")
        end
      end
      
      before(:each) do
        @files = processor.initialize_file_objects('recycling1.txt;recycling2.txt;garbage1.txt')
      end
      
      it "should return 37 rows/sentences. 36 regular, 1 empty" do
        processor.retrieve_content_rows(@files).size.should == 37
      end
      
      it "should return 2 rows" do
        processor.retrieve_content_rows(processor.initialize_file_objects('testfile_rspec.txt')).size.should == 2
      end
      
      after(:all) do
        File.delete('recycling1.txt')
        File.delete('recycling2.txt')
        File.delete('garbage1.txt')
        File.delete('testfile_rspec.txt')
      end
    end
    
    describe "#output_files_to_csv" do
      before(:all) do
        create_test_files
      end
      before(:each) do
        @files = processor.initialize_file_objects('recycling1.txt;recycling2.txt;garbage1.txt')
      end
      
      after(:each) do
        if File.exists?('out.csv')
          File.delete('out.csv')
        end
      end
      
      after(:all) do
        File.delete('recycling1.txt')
        File.delete('recycling2.txt')
        File.delete('garbage1.txt')
      end
      
      it "should create an out.csv file" do
        processor.output_files_to_csv(@files)        
        File.exists?('out.csv').should be_true
      end
      
      it "out.csv should have 38 rows" do
        processor.output_files_to_csv(@files)
        File.readlines('out.csv').size.should == 38
      end
      
    end
  end
end