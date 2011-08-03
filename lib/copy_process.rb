# require 'copy_process/content_element'
# require 'copy_process/content_row'
# require 'copy_process/processor'

module CopyProcess
  # Gets the index of a value inside an array of the given array
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
end
