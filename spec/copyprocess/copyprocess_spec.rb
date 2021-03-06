require 'spec_helper'

module CopyProcess
  describe CopyProcess do
    include CopyProcess
    
    describe "#enclose" do
      context "text contains a comma" do
        it "should enclose in double quotes" do
          Helpers::enclose('some, string').should == '"some, string"'
        end
      end
      context "text does contain a comma" do
        it "should not be enclosed" do
          Helpers::enclose('some string').should == 'some string'
        end
      end
    end
    
    describe "#includes_inner?" do
      before(:each) { @arr = [['aaa', '3'], ['bsdw', '2'], ['aabcd', '4'], ['aaron', '5']] }
      it "contains the given value" do
        includes_inner?('aaa', @arr).should be_true
      end
      
      it "does not contain the value" do
        includes_inner?('some non existant value', @arr).should_not be_true
      end
    end
    
    describe CopyFile do
      before(:each) do
        @valid_headers = "/*\nType: Some Keyword \nLayer: State \nVariation: 1 \n*/\n"
        @cf = CopyFile.new(@valid_headers + 'some content', 'Some keyword', 'State layer', '3', 'copytext.txt')
      end
      
      # helper methods
      def four_sentence_array(paragraph = "")
        paragraph = paragraph != "" ? paragraph : "A sentence* with an asterisk. Another sentence. This paragraph rocks, what do you think? It's cool!"
        sentences = @cf.content_sentence_split_helper(paragraph, 'P1', '')
      end

      def expected_format(cf, element_name, counter, s_counter, sentence)
        if s_counter == 0
          s_counter = ''
        else
          s_counter = " S#{s_counter}"
        end
        "#{cf.layer} #{element_name}#{counter}#{s_counter},#{Helpers::enclose(sentence)},#{cf.note}"
      end
      
      describe "#initialize" do
        it "should have its attributes set properly" do          
          @cf.contents.should == @valid_headers + 'some content'
          @cf.type.should == 'Some keyword'
          @cf.layer.should == 'State layer'
          @cf.variation.should == '3'
          @cf.file_name.should == 'copytext.txt'
        end
      end
      
      describe "#parse_file" do
        
        def test_number_of_elements_with_content(content, expectation)
          @cf.contents = content
          @cf.parse_file
          @cf.elements.size.should == expectation
        end
        context "contents contains 4 keys" do          
          it "should result in an elements collection of 4" do
            
            test_number_of_elements_with_content(
              "#{@valid_headers}HEAD: A header\nBODY: Some body\nBODY: Another body\nFOOTER: A footer",
              4
            )
          end
        end
        
        context "contents contains 5 keys" do
          it "should result in an elements collection of 5" do     
            test_number_of_elements_with_content(
              "#{@valid_headers}HEAD: A header\nBODY: Some body\nBODY: Another body\nFOOTER: A footer\nCTA: A call to action" +
              "FakeHeader: not a header",
              5
            )
          end
          
          it "with a mix of names, it should result in an elements collection of 5," do
            test_number_of_elements_with_content(
              "#{@valid_headers}HEAD: A header\nBODY: Some body\nBODY: Another body\nFEATURE 1: A footer\nFEATURE 1 BODY: A call to action",
              5
            )
          end
          
          it "with caps in the content, it should still have 5" do
            test_number_of_elements_with_content(
              "#{@valid_headers}HEAD: A header\nBODY: Some body\nBODY: Another body\nFOOTER: ZOMG, YAY!\nCTA: A call to action",
              5
            )
          end
        end
        
        context "contains 3 keys" do
          it "should contain accurate key/value pairs" do
            test_number_of_elements_with_content(
              "#{@valid_headers}HEAD: A header\nBODY: Some body\nBODY: Another body",
              3
            )
            first, second, third = @cf.elements[0], @cf.elements[1], @cf.elements[2]
            first.name.should == "HEAD"
            first.content.should == "A header"
            
            second.name.should == "BODY"
            second.content.should == "Some body"
            
            third.name.should == "BODY"
            third.content.should == "Another body"
          end
        end
      end
      
      describe "#note" do
        it "should equal variation-type" do
          @cf.note.should == '3-Some keyword'
        end
      end
      
      context "A set element_names array" do
        before(:each) do 
          @element_names = [
            ['Header', 2],
            ['P1', 1],
            ['Footer', 5]
          ]
        end
        
        describe "#set_element_name_and_counter" do
          it "should append a new name and counter of 1" do
            names = @cf.set_element_name_and_counter(@element_names, 'Body')
            names.last[0].should == 'Body'
            names.last[1].should == 1
          end
        
          it "should increment the existing counter" do
            current_counter = @element_names[get_inner_index('Footer', @element_names)][1]
            names = @cf.set_element_name_and_counter(@element_names, 'Footer')
            names[get_inner_index('Footer', @element_names)][1].should == current_counter + 1
          end
        end
      
        describe "#set_element_counter" do
          it "should use its set counter in the array" do
            @cf.set_element_counter(@element_names, 'Footer').should == 5
            @cf.set_element_counter(@element_names, 'Header').should == 2
          end
          
          it "should use its own counter" do
            @cf.set_element_counter(@element_names, 'Body2') == 2
          end
        end
      end
      describe "#content_sentence_split_helper" do
        context "Sentence with valid separators" do
          it "should return an array with 4 sentences" do              
            four_sentence_array.size.should == 4
          end
          
          it "should be formatted correctly" do
            ce1 = four_sentence_array[0]
            ce2 = four_sentence_array[1]
            ce3 = four_sentence_array[2]
            
            ce1.content.should == expected_format(@cf, 'P1', '', 1, 'A sentence* with an asterisk.')
            ce2.content.should == expected_format(@cf, 'P1', '', 2, 'Another sentence.')
            ce3.content.should == expected_format(@cf, 'P1', '', 3, 'This paragraph rocks, what do you think?')
          end
          
          it "should return 4 sentences, even with a url in it." do
            four_sentence_array("A sentence* with an asterisk. Another sentence. This paragraph rocks, agmprojects.com? It's cool!").size.should == 4
          end
          
          it "Url sentence should still contain the url" do
            four_sentence_array("A sentence* with an asterisk. Another sentence. This paragraph rocks, agmprojects.com? It's cool!").size[2] == "This paragraph rocks, agmprojects.com?"
          end
        end
      end
      
      describe "#escape_links" do
        subject { @cf.escape_links(paragraph) }
        context "multiple sentences" do
          let(:paragraph) { "A sentence* with an asterisk. A second sentence going to google.com." }
          it { should == "A sentence* with an asterisk. A second sentence going to google~@@com." }
        end
        
        context "with http" do
          let(:paragraph) { "Here you go http://www.google.com!" }
          it { should == "Here you go http://www.google~@@com!" }
        end
        
        context "inside a link" do
          let(:paragraph) { 'Go <a href="http://www.google.com">here</a>' }
          it { should == 'Go <a href="http://www.google~@@com">here</a>' }
        end
      end
      
      describe "#unescape_links" do
        subject { @cf.unescape_links(paragraph) }
        
        context "multiple links" do
          let(:paragraph) { "http://google~@@com and http://admin.ptdev.dacgroup~@@ca" }
          it { should == "http://google.com and http://admin.ptdev.dacgroup.ca" }
        end
        
        context "inside an anchor tag" do
          let(:paragraph) { '<a href="http://www.google~@@com">google</a>' }
          it { should == '<a href="http://www.google.com">google</a>' }
        end
      end
      
      describe "#append_content_to_array" do
        context "Empty content array" do
          before(:each) do
            element = ContentElement.new('HEADER', 'A header')
            @array = @cf.append_content_to_array([], element, 1)
          end
          it "should be the size of 1" do
            @array.size.should == 1
          end
          
          it "should be the size of 4" do
            ce = ContentElement.new('BODY', 'A sentence. Sentence 2. A question? Yes')
            @cf.append_content_to_array([], ce, 1).size.should == 4
          end
          
          it "should be a ContentRow object" do
            @array.first.class.should == ContentRow
          end          
        end
      end
    
      describe "#elements_out" do
        context "Elements variable populated with 5 ContentElements" do
          before(:each) do
            @cf.contents = "#{@valid_headers}HEAD: A header\nBODY: Some body\nCTA: Callto action\nBODY: Another body FOOTER: A footer"
            @cf.parse_file
          end
          
          it "should return a collection of 4" do
            @cf.elements_out.size.should == 4
          end
          
          it "first element should return correct contents" do
            cr = @cf.elements_out.first
            cr.content.should == expected_format(@cf, 'HEAD1', '', 0, 'A header')              
          end
        end  
        
        it "should return a collection 8" do
          @cf.contents = "#{@valid_headers}HEAD: A header\nBODY: Some body. With a sentence. And a question? and a sentence\nCTA: Callto action\nBODY: Another body\nFOOTER: A footer"
          @cf.parse_file
          @cf.elements_out.size.should == 8
        end    
      end
    end
  end
end
