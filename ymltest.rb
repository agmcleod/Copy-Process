lines = []
File.open('state-mobile-offices.txt', 'r+') do |file|
  file.each_line do |line|
    line = line.gsub(/\t|\n/, '')
    unless line == '' || line == ' '
      lines << line
    end
  end
end

File.open('tst.txt', 'w+') do |file|
  lines.each { |e| file.write("#{e}\n") }
end