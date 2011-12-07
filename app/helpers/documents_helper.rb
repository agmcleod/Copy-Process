module DocumentsHelper
  def content_with_notes(version)
    content = h(version.content)
    offset = 0
    
    notes = []
    
    version.notes.each do |note|
      tag = "<span class=\"to_change\" id=\"sel_#{note.id}\">"
      close_tag = '</span>'
      
      content.insert(note.start_character + offset, tag)
      offset += tag.size
      content.insert(note.end_character + offset, close_tag)
      offset += close_tag.size
    end
    
    content.html_safe
  end
  
end
