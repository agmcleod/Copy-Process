file_contents_retrieved = false
require "./copy_process.rb"
include CopyProcess

# initalizes file array
files = []

puts "Please enter in the file path to the text document you wish to parse.\nSeparate multiple file names by using a semicolon."
contents = gets.chomp

# initialize variables
file_contents = ""
headers = ""

# if they entered a value, continue on
unless contents.nil? || contents == ''
  # set the string to empty, so it doesn't concatenate with previous data
  file_names = contents.split(';')
  file_names.each do |file_name|
    file_contents = ""
    begin
      File.open(file_name.strip, 'r+') do |file| 
        file.each_line do |line|
          line = line.gsub(/\t|\n/, '').strip
          file_contents = "#{file_contents}#{line}\n" unless line == ''
        end
      end
      headers = contains_valid_headers(file_contents)
      unless headers
        raise "Headers not found in file: #{file_name}"
      else
        files << CopyFile.new(file_contents, headers[0], headers[1], headers[2], file_name)
      end
    rescue Errno::ENOENT
      puts "  Error => File not found: #{file_name}"
    end 
  end
end

File.open('out.csv', 'w+') do |f|
  f.write "ParentType,TypeID,ElementID,ParentTypeName,TypeName,Content,Notes\n"
  files.each do |file_obj|
    file_obj.elements_out.each do |ele|
      f.write ",,,,#{ele}\n"
    end
  end
end