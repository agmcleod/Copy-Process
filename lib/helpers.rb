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
  # @param [Boolean] - whether to escape double quotes or not. Default to true
  # @return [String]
  def self.enclose(string, escape_quotes = true)
    begin
      string = string.gsub(/\u2019/, '&rsquo;')
    rescue NoMethodError => ex
      raise "Something came back null in one of the elements. Double check the names & formatting in your documents, and re-compile. " + 
      "\n#{ex.message}\n#{ex.backtrace}"
    end
    string.gsub!(/\"/, "&quot;") if escape_quotes
    if string.index(',')
      "\"#{string}\""
    else
      string
    end
  end
end