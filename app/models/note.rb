class Note < ActiveRecord::Base
  belongs_to :document
  
  validate :note_does_not_overlap
  
  private
  
  def note_does_not_overlap
    notes = Note.where(['((start_character < ? AND end_character > ?) OR (start_character < ? AND end_character > ?)) AND document_id = ?', 
      self.start_character, self.start_character, self.end_character, self.end_character, self.document_id])
    
    unless notes.empty?
      errors[:start_character] << "Selection must be unique. Cannot overlap other selections"
    end
  end
  
end
