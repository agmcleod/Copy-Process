module CopyProcess
  class Processor
    attr_accessor :input
    def compile_files_to_csv(files)
      output = "ParentTypeID,TypeID,ElementID,ParentTypeName,TypeName,Content,Notes\n"
      retrieve_content_rows(files).each do |r|
        output << ",,,,#{r}\n"
      end
      output
    end
    
    def retrieve_content_rows(files)
      final_rows = []
      types_and_keywords = []
      keywords = []
      types = []
      files.each do |file_obj|
        file_obj.elements_out.each do |ele|
          keywords << ele.kw unless keywords.include?(ele.kw)
          types << ele.type_name unless types.include?(ele.type_name)
          final_rows << ele.content
          types_and_keywords << "#{ele.type_name}+#{ele.kw}" unless types_and_keywords.include?("#{ele.type_name}+#{ele.kw}")
        end
      end
      add_missing_elements(final_rows, keywords, types, types_and_keywords)
    end
    
    def parse_each_document(content, files)
      headers = contains_valid_headers(content)
      append_file_if_valid(content, headers, files, '')
    end

    # Returns the file names in the correct format
    # @params [String] contents - entered file names
    # @return [Array] returns an array of the file names
    def set_file_names(contents)
      if contents.match(/^\*\.[a-z]{1,}/).nil?
        contents.split(';')
      else
        Dir[contents]
      end
    end

    def append_file_if_valid(file_contents, headers, files, file_name)
      unless headers
        raise "Headers not found in file: #{file_name}"
      else
        files << CopyProcess::CopyFile.new(file_contents, headers[0], headers[1], headers[2], file_name)
      end
    end
    
    # Adds missing element variations for restriction purposes.
    def add_missing_elements(final_rows, keywords, types, types_and_keywords)
      keywords.each do |k|
        types.each do |t|
          unless types_and_keywords.include?("#{t}+#{k}")
            final_rows << "#{t},<!-- empty -->,empty for: #{k}"
          end
        end
      end
      final_rows
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
  end
end