module CopyProcess
  # This method confirms the content of the text file has valid HEADER values.
  # @param [String] value - a string containing the contents from the text file
  # @return [Array]
  def contains_valid_headers(value)
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
  
  # Encloses the string in double quotes, in case it contains a comma
  # @param [String] - the string to enclose
  # @return [String]
  def enclose(string)
    if string.index(',')
      return "\"#{string}\""
    else
      return string
    end
  end
  
  class CopyFile
    attr_accessor :contents, :type, :layer, :variation, :content_headers, :paragraphs, :ctas, :footer
    def initialize(contents, type, layer, variation, file_name)
      @file_name = file_name
      @contents = contents
      @type = type
      @layer = layer
      @variation = variation
      @content_headers = parse_content_headers
      @paragraphs = parse_paragraphs
      @ctas = parse_ctas
      @cta_hs = parse_cta_hs
      @bullet_headers = parse_bullet_headers
      @bullets = parse_bullets
      @footer = parse_footer
    end
    
    def to_s
      "\nHeaders: \n#{@content_headers.join("\n")}\n\nParagraphs: \n#{@paragraphs.join("\n")}\n\nCTAS: \n#{@ctas.join("\n")}\n\nFooter: \n#{@footer.join("\n")}"
    end
    
    # parses the copy headers from the text file
    # @return [Array]
    def parse_content_headers
      find_content('~')
    end
    
    # parses out the pargraphs from the text file
    # @return [Array]
    def parse_paragraphs
      find_content('||')
    end
    
    # parses out the call to actions from text file
    # @return [Array]
    def parse_ctas
      find_content('//')
    end
    
    # parses out the call to actions headers from text file
    # @return [Array]
    def parse_cta_hs
      find_content('/|')
    end
    
    # parses out the footer from the text file
    # @return [Array]
    def parse_footer
      find_content('`')
    end
    
    # parses out the bullet header(s) from the text file
    # @return [Array]
    def parse_bullet_headers
      find_content('\\|')
    end
    
    # parses out the bullets from the text file
    # @return [Array]
    def parse_bullets
      find_content('@@')
    end
    
    # returns the string to use in the note field of the CSV
    # @return [String]
    def note
      return "#{@variation}-#{@type}"
    end
    
    # returns all the content as an array
    # @return [Array]
    def foreach_content
      return [headers_out, ctas_out, paragraphs_out, footer_out]
    end
    
    # Takes the array of headers, and formats them for the CSV
    # @return [Array] - array of the formatted headers
    def headers_out
      headers_to_return = []
      counter = 0
      ele_name = 'Header'
      @content_headers.each do |header|
        ele_name = "Sub Header #{counter}" if counter > 0
        headers_to_return << "#{@layer} #{ele_name},#{enclose(header)},#{self.note}"
        counter += 1
      end
      return headers_to_return
    end
    
    # Takes the array of CTAs, and formats them for the CSV
    # @return [Array] - array of the formatted ctas
    def ctas_out
      ctas_to_return = []
      counter = 1
      @ctas.each do |cta|
        ctas_to_return << "#{@layer} CTA#{counter},#{enclose(cta)},#{self.note}"
        counter += 1
      end      
      return ctas_to_return
    end
    
    # Take the array of CTA Headers, and formats them for the CSV
    # @return [Array] - array of the formatted cta headers
    def cta_headers_out
      ctas_to_return = []
      counter = 1
      @cta_hs.each do |cta|
        ctas_to_return << "#{@layer} CTA H#{counter},#{enclose(cta)},#{self.note}"
        counter += 1
      end
      
      return ctas_to_return
    end
    
    # Take the array of Bullet Headers, and formats them for the CSV
    # @return [Array] - array of the formatted Bullet headers
    def bullet_headers_out
      bh_to_return = []
      counter = 1
      @bullet_headers.each do |bh|
        bh_to_return << "#{@layer} Bullet H#{counter},#{enclose(bh)},#{self.note}"
        counter += 1
      end      
      return bh_to_return
    end
    
    # Take the array of Bullet Points (one point = one unordered list usually), and formats them for the CSV
    # @return [Array] - array of the formatted bullet points
    def bullets_out
      b_to_return = []
      counter = 1
      @bullets.each do |b|
        b_to_return << "#{@layer} Bullets #{counter},#{enclose(b)},#{self.note}"
      end
      counter += 1
      return b_to_return
    end
    
    # Returns an array of the footer (or footers) split up sentence by sentence
    # Formatted for the CSV
    # @return [Array] - array of the formatted footer(s)
    def footer_out
      return content_sentence_split_helper(@footer, "Footer")
    end
    
    def out_methods
      [:headers_out, :ctas_out, :cta_headers_out, :paragraphs_out, :bullet_headers_out, :bullets_out, :footer_out]
    end
    
    # this is used to parse content that contains multiple sentences that should be split
    # It loops through the given content, splits it by an asterisk, and appends the appropriate content
    def content_sentence_split_helper(contents, ele_name)
      counter = 1
      to_return = []
      contents.each do |content|
        sentences = content.split('*')
        s_counter = 0
        sentences.each do |sentence|
          sentence.strip!
          s_counter += 1
          to_return << "#{@layer} #{ele_name}#{counter} S#{s_counter},#{enclose(sentence)},#{self.note}"
        end
        counter += 1
      end
      return to_return
    end
    
    # Returns an array of the paragraphs split up sentence by sentence
    # Formatted for the CSV
    # @return [Array] - array of the formatted paragraphs
    def paragraphs_out
      return content_sentence_split_helper(@paragraphs, "P")
    end
    
    # This grabs the content between two given separators from a given string.
    # It returns each section found as an array
    # @param[String] content - the text file content
    # @param[String] separator - the separator to look for
    # @return [Array]
    def find_content(separator)
      # used for indexing offset
      sz = separator.size
      done = false
      content_array = []
      last_index = 0
      until done
        idx = @contents.index(separator, last_index)
        if idx.nil?
          done = true
        else
          closing_idx = @contents.index(separator, idx+sz)
          if closing_idx.nil?
            puts "Document #{@file_name} not properly formatted, missing a: #{separator}"
            done = true
            return false
          else
            content_array << @contents[idx+sz..closing_idx-1].gsub(/\n|\t/, '')
            last_index = closing_idx + 1
          end
        end
      end
      return content_array
    end
  end
  # end of CopyFile class
end