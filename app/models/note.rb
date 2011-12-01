class Note < ActiveRecord::Base
  belongs_to :version
  
  validate :note_does_not_overlap
  
  private
  
  def note_does_not_overlap
    notes = Note.where(['((start_character < ? AND end_character > ?) OR (start_character < ? AND end_character > ?)) AND version_id = ?', 
      self.start_character, self.start_character, self.end_character, self.end_character, self.version_id])
    
    unless notes.empty?
      errors[:start_character] << "Selection must be unique. Cannot overlap other selections"
    end
  end
  
end
