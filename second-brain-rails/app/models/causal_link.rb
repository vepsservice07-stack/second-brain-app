class CausalLink < ApplicationRecord
  belongs_to :cause_note, class_name: 'Note'
  belongs_to :effect_note, class_name: 'Note'
  
  validates :cause_note_id, presence: true
  validates :effect_note_id, presence: true
  validates :strength, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  
  # Prevent self-links
  validate :cannot_link_to_self
  
  # Ensure causal ordering (cause must come before effect)
  validate :causal_ordering
  
  private
  
  def cannot_link_to_self
    if cause_note_id == effect_note_id
      errors.add(:base, 'Cannot create causal link to self')
    end
  end
  
  def causal_ordering
    return unless cause_note && effect_note
    
    if cause_note.sequence_number && effect_note.sequence_number
      if cause_note.sequence_number >= effect_note.sequence_number
        errors.add(:base, 'Cause must precede effect in sequence')
      end
    end
  end
end
