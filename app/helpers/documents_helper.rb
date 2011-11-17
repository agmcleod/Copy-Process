module DocumentsHelper
  def content_with_notes(document)
    content = h(document.content)
    offset = 0
    
    notes = []
    
    document.notes.each do |note|
      tag = "<span class=\"to_change\" id=\"sel_#{note.id}\">"
      close_tag = '</span>'
      
      content.insert(note.start_character + offset, tag)
      offset += tag.size
      content.insert(note.end_character + offset + 1, close_tag)
      offset += close_tag.size
    end
    
    content.html_safe
  end
  
  
  def add_notes_to_page(document)
    out = ''
    document.notes.each do |note|
      out << note_html(note)
    end
    out.html_safe
  end
  
  def note_html(note)
    "<div class=\"note\" id=\"note_#{note.id}\"><p>#{note.body}</p><cite>#{note.author}</cite></div>"
  end
  
end
