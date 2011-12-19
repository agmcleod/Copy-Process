module DocumentsHelper
  def content_with_notes(version)
    content = h(version.content)
    offset = 0
    
    notes = []
    Rails.logger.debug("Content h'd: #{content[0..20]}")
    
    version.notes.each do |note|
      tag = "<span class=\"to_change\" id=\"sel_#{note.id}\">"
      close_tag = '</span>'
      
      content.insert(note.start_character + offset, tag)
      offset += tag.size
      content.insert(note.end_character + offset, close_tag)
      offset += close_tag.size
    end
    
    Rails.logger.debug("Content final: #{content[0..20]}")
    
    content.html_safe
  end
  
end
