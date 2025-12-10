class NoteLink < ApplicationRecord
  belongs_to :source_note, class_name: 'Note'
  belongs_to :target_note, class_name: 'Note'
  
  validates :source_note_id, uniqueness: { scope: :target_note_id }
  validates :link_type, inclusion: { in: %w[references builds_on contradicts related] }
  
  validate :cannot_link_to_self
  
  private
  
  def cannot_link_to_self
    if source_note_id == target_note_id
      errors.add(:target_note_id, "cannot link note to itself")
    end
  end
end
