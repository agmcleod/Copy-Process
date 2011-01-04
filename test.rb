require './content_element'
contents = IO.read('home-inspection.txt')

done = false
idx = 0
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
      content_elements << ContentElement.new(et.strip, contents[idx..next_et])
    end
  end
end
File.open('testout.txt', 'w+') do |f|
  content_elements.each { |e| f.write "#{e.name} #{e.content.gsub(/\n/, '')}\n" }
end