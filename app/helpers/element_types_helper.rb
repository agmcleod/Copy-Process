module ElementTypesHelper
  
  def show_element_content(element_types, site)
    loop_through_elements(element_types) do |output, last|
      element_types.each do |ele|
        if last != get_element_type_name(ele.name)
          last = get_element_type_name(ele.name)
          output << "</ul></div><h3><a href=\"#\">#{last}</a></h3><div><ul>"
        end
        output << "<li>#{link_to(get_element_content(ele.name), site_element_type_path(site, ele.id))}</li>"
      end
    end
  end
  
  def loop_through_elements(element_types, &block)
    last = get_element_type_name(element_types.first.name)
    output = "<h3><a href=\"#\">#{last}</a></h3><div><ul>"
    if last.nil?
      raise "ElementReturnedNullException - this shouldn't happen."
    else
      yield(output, last)
      output << "</ul></div>"
    end
    output.html_safe
  end
  
  def list_elements(element_types)
    loop_through_elements(element_types) do |output, last|
      element_types.each do |ele|
        if last != get_element_type_name(ele.name)
          last = get_element_type_name(ele.name)
          output << "</ul></div><h3><a href=\"#\">#{last}</a></h3><div><ul>"
        end
        output << "<li>#{get_element_content(ele.name)}<ul>"
        ele.elements.each do |element|
          output << "<li>#{h(element.content)}</li>"
        end
        output << "</ul>"
      end
    end
  end
  
  def get_element_type_name(ele)
    ele.split(" ")[0]
  end
  
  def get_element_content(ele)
    words = ele.split(" ")
    words[1..words.size].join(" ")
  end
end
