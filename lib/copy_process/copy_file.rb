module CopyProcess
  class CopyFile
    require 'helpers'
    require 'nokogiri'
    
    include Helpers
    attr_accessor :contents, :type, :layer, :variation, :file_name
    attr_reader :elements
    def initialize(contents, type, layer, variation, file_name)
      @file_name = file_name
      @contents = contents
      @type = type
      @layer = layer
      @variation = variation
      @elements = []
      parse_file
      # init_elements
    end

    # Parses a text file of the pasted contents from the word doc, and formats it properly.
    # @return void
    def parse_file
      done = false
      idx = 0
      contents = @contents.split(/\n/)
      contents = contents[5..contents.size-1]
      contents = contents.join('\n')
      content_elements = []
      r = /((([A-Z]\s?)|([0-9]\s?)){1,}){1,}\s?:/
      until done
        et = r.match(contents, idx)
        if et.nil?
          done = true
        else
          et = et.to_s
          unless et.empty?
            idx = contents.index(et, idx) + et.size + 1
            next_et = r.match(contents, idx)
            if next_et.nil?
              next_et = contents.size 
            else
              next_et = next_et.to_s
              next_et = contents.index(next_et, idx)
            end
            @elements << ContentElement.new(et.strip.gsub(/:/,''), contents[idx-1..next_et-1].gsub(/\n|\\n|\r|\t/, '').strip)
          end
        end
      end
    end

    # returns the string to use in the note field of the CSV
    # @return [String]
    def note
      if @type == ""
        return ""
      else
        return "#{@variation}-#{@type}"
      end
    end

    # checks if element names contains the current element object. If not, add it and set the number of occurances to 1
    # @param element_names [Array] - contains arrays of an element type name, and how many times it has occured. The name is unique
    # @param name [String] - The name of the element type
    # @return element_names [Array] - return the updated array
    def set_element_name_and_counter(element_names, name)
      if !includes_inner?(name, element_names)
        element_names << [name, 1]
      else
        # if it's in the array already, find it and increment the counter
        current_element = element_names[get_inner_index(name, element_names)]
        element_names[get_inner_index(name, element_names)] = [current_element[0], current_element[1]+1]
      end
      element_names
    end

    # if an element contains its own numbering, don't bother with a counter
    # @param element_names [Array] - contains arrays of an element type name, and how many times it has occured. The name is unique
    # @param name [String] - The name of the element type
    # @return counter [String] - Empty if the name has a counter, or returns the current count
    def set_element_counter(element_names, name)
      if name.index(/[1-9]/)
        ''
      else  
        element_names[get_inner_index(name, element_names)][1]
      end
    end

    # Formats the content element types to be put in the csv
    # @return [Array] output_array
    def elements_out
      # create the arrays required
      element_names = []
      output_array = []
      # loop through each content element object
      @elements.each do |element|
        element_names = set_element_name_and_counter(element_names, element.name)
        counter = set_element_counter(element_names, element.name)
        # if the content is marked up to be split, split it up.
        output_array = append_content_to_array(output_array, element, counter)
      end
      output_array
    end

    # Appends the contents to the array as required. Either splits the sentences of a paragraph, or adds the current element
    # @param [Array] output_array - the array to append to
    # @param [ContentElement] element - the element object to add to the array
    # @param [int] counter - the counter needed to mark the element type
    # @return [Array] output_array
    def append_content_to_array(output_array, element, counter)
      if element.content.scan(/[.!?]/).size > 1
        content_sentence_split_helper(element.content, element.name, counter).each do |sentence|
          output_array << sentence
        end
      else
        et_name = "#{@layer} #{element.name}#{counter}"
        output_array << ContentRow.new(et_name, "#{et_name},#{enclose(element.content)},#{self.note}", self.type)
      end
      output_array
    end

    # this is used to parse content that contains multiple sentences that should be split
    # It loops through the given content, splits it by an asterisk, and appends the appropriate content
    def content_sentence_split_helper(contents, ele_name, counter)
      to_return = []
      vals = escape_punctuation_in_html(contents)
      contents, replaced = vals[0], vals[1]
      
      sentences = contents.split(/(?<=[.!?])(?!\*)/)
      if replaced || sentences.size == 1
        sentences[0] = sentences[0].strip.gsub(/\n/, '')
        et_name = "#{@layer} #{ele_name}#{counter}"
        to_return << ContentRow.new(et_name, "#{et_name},#{enclose(sentences[0])},#{self.note}", self.type)
      else
        sentences.each_with_index do |sentence, s_counter|
          # remove whitespace
          sentence.strip!
          et_name = "#{@layer} #{ele_name}#{counter} S#{s_counter + 1}"
          to_return << ContentRow.new(et_name, "#{et_name},#{enclose(sentence)},#{self.note}", self.type)
        end
      end
      return to_return
    end
    
    def escape_punctuation_in_html(contents)
      doc = Nokogiri::HTML::DocumentFragment.parse(contents)
      is_html = false
      doc.search("*").each do |node|
        if node.element?
          is_html = true
        end
        dummy = node.add_previous_sibling(Nokogiri::XML::Node.new("dummy", doc))
        dummy.add_previous_sibling(Nokogiri::XML::Text.new(node.to_s.gsub(/(?<=[.!?])(?!\*)/, "#{$1}*"), doc))
        node.remove
        dummy.remove
      end
      return [doc.to_html.to_s.gsub("&lt;", "<").gsub("&gt;", ">"), is_html]
    end
  end
end