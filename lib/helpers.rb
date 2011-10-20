module Helpers
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
    begin
      string = string.gsub(/\u2019/, '&rsquo;')
    rescue NoMethodError => ex
      raise "Something came back null in one of the elements. Double check the names & formatting in your documents, and re-compile. " + 
      "\n#{ex.message}\n#{ex.backtrace}"
    end
    if string.index(',')
      return "\"#{string}\""
    else
      return string
    end
  end
end