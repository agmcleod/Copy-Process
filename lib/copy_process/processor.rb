module CopyProcess
  class Processor
    require 'csv'
    include Helpers
    
    attr_accessor :input
    def compile_files_to_csv(site, with_parents)
      if site.element_types.size > 0
        headers = ["ParentTypeID,TypeID,ElementID,ParentTypeName,TypeName,Content,Notes"]
        parent_names = []
        output = ""
        site.element_types.each do |et|
          et.elements.each do |e|
            if with_parents
              pn = et.name.split(' ').first
              output << ",,,#{pn},#{Helpers::enclose(et.name)},#{Helpers::enclose(e.content.gsub("&quot;", "\""), false)},#{e.note}\n"
              parent_names << pn unless parent_names.include?(pn)
            else
              output << ",,,,#{Helpers::enclose(et.name)},#{Helpers::enclose(e.content.gsub("&quot;", "\""), false)},#{e.note}\n"
            end
          end
        end
        
        parent_names.each do |pn|
          headers << ",,,,#{pn},<!-- -->,"
        end
        
        [headers.join("\n"), output].join("\n")
      else
        ''
      end
    end
    
    def compile_files_to_element_types(files, site)
      types = []
      rows = {}
      retrieve_content_rows(files).each do |r|
        Rails.logger.debug("R: #{r}")
        row = CSV.parse_line(r)
        if rows[row[0]].nil?
          rows[row[0]] = [row]
        else
          rows[row[0]] << row
        end
      end
      should_save = false
      rows.each_key do |k|
        et = site.element_types.build(:name => k)
        rows.each_value do |row|
          if et.name == row[0][0]
            row.each do |r|
              et.elements.build(:content => r[1], :note => r[2])
            end
            should_save = true
          end
        end
      end
      site.save! if should_save
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

    def append_file_if_valid(file_contents, headers, files, file_name)
      unless headers
        raise "Headers not found in file: #{file_name}"
      else
        files << CopyFile.new(file_contents, headers[0], headers[1], headers[2], file_name)
      end
    end
    
    # Adds missing element variations for restriction purposes.
    def add_missing_elements(final_rows, keywords, types, types_and_keywords)
      used_types = []
      keywords.each do |k|
        types.each do |t|
          if !types_and_keywords.include?("#{t}+#{k}") && !used_types.include?(t)
            used_types << t
            final_rows << "#{t},<!-- empty -->,empty for restrictions"
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