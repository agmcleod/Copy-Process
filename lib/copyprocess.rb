require 'copyprocess/content_element'
require 'copyprocess/content_row'

module CopyProcess  
  def get_inner_index(value, arr)
    idx = nil
    arr.each_with_index do |e, i|
      if e[0] == value
        idx = i
      end
    end
    return idx
  end
  
  def includes_inner?(value, arr)
    bool = false
    arr.each { |e| bool = true if e[0] == value  }
    return bool
  end
  # This method confirms the content of the text file has valid HEADER values.
  # @param [String] value - a string containing the contents from the text file
  # @return [Array]
  def contains_valid_headers(value)
    split_value = value.split(/\n/)
    if split_value.size == 0 || split_value[4].nil?
      return false
    else
      if(split_value[0].index('/*').nil? || split_value[4].index('*/').nil?)
        return false
      else
        start_index = value.index('/*')
        return false if start_index.nil?
        end_index = value.index('*/', start_index+2)
        return false if end_index.nil?
        value = value[start_index+2..end_index-1]
      
        type_i = value.index('Type:')
        layer_i = value.index('Layer:')
        variation_i = value.index('Variation:')
        return false if type_i.nil? || layer_i.nil? || variation_i.nil?
        # sets the type, layer, variation as an array
        headers = [value[type_i+5..layer_i-1], value[layer_i+6..variation_i-1], value[variation_i+10..value.size]]
        # return it with each value stripped of nextline characters and extra white space
        return headers.collect { |c| c.gsub(/\n|\t/, '').strip }
      end
    end
  end
  
  # Encloses the string in double quotes, in case it contains a comma
  # @param [String] - the string to enclose
  # @return [String]
  def enclose(string)
    string = string.gsub(/\u2019/, '&rsquo;')
    if string.index(',')
      return "\"#{string}\""
    else
      return string
    end
  end
  
  
  
  class CopyFile
    include CopyProcess
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
      until done
        et = /([A-Z]{1,}|\s){1,}:/.match(contents, idx)
        if et.nil?
          done = true
        else
          et = et.to_s
          unless et.empty?
            idx = contents.index(et, idx) + et.size + 1
            next_et = /([A-Z]{1,}|\s){1,}:/.match(contents, idx)
            if next_et.nil?
              next_et = contents.size 
            else
              next_et = next_et.to_s
              next_et = contents.index(next_et, idx)
            end
            @elements << ContentElement.new(et.strip.gsub(/:/,''), contents[idx-1..next_et-1].gsub(/\n|\\n/, '').strip)
          end
        end
      end
    end
    
    # returns the string to use in the note field of the CSV
    # @return [String]
    def note
      return "#{@variation}-#{@type}"
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
        if element.content.index('*')
          content_sentence_split_helper(element.content, element.name, counter).each do |sentence|
            output_array << sentence
          end
        else
          et_name = "#{@layer} #{element.name}#{counter}"
          output_array << ContentRow.new("#{et_name},#{enclose(element.content)},#{self.note}", et_name, self.type)
        end
      end
      output_array
    end
    
    # this is used to parse content that contains multiple sentences that should be split
    # It loops through the given content, splits it by an asterisk, and appends the appropriate content
    def content_sentence_split_helper(contents, ele_name, counter)
      to_return = []
      sentences = contents.split(/(?<=[.!?])\*/)
      sentences.each_with_index do |sentence, s_counter|
        # remove whitespace
        sentence.strip!
        et_name = "#{@layer} #{ele_name}#{counter} S#{s_counter + 1}"
        to_return << ContentRow.new("#{et_name},#{enclose(sentence)},#{self.note}", et_name, self.type)
      end
      return to_return
    end
    
  end
  # end of CopyFile class
end
