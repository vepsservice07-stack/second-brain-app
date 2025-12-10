class TimelineBranch < ApplicationRecord
  belongs_to :note
  
  # Find divergence points (where user deleted then wrote something else)
  def self.detect_branches(note_id)
    interactions = Interaction.for_note(note_id).ordered
    branches = []
    
    # Look for delete followed by different insert
    interactions.each_cons(50) do |window|
      deletions = window.select { |i| i.interaction_type.in?(['delete', 'backspace']) }
      
      next if deletions.empty?
      
      # Significant deletion (3+ chars)
      if deletions.count >= 3
        divergence_seq = deletions.first.sequence_number
        
        # What was deleted?
        deleted_content = reconstruct_deleted(deletions)
        
        # What was written instead?
        after_deletion = window.drop_while { |i| i.interaction_type.in?(['delete', 'backspace']) }
        new_content = after_deletion.take(10).map(&:char).join
        
        branches << {
          divergence_sequence: divergence_seq,
          deleted_branch: deleted_content,
          current_branch: new_content,
          reason: analyze_divergence_reason(divergence_seq, note_id)
        }
      end
    end
    
    branches
  end
  
  def self.reconstruct_deleted(deletions)
    # Try to figure out what was deleted
    # In production, would track this explicitly
    deletions.map(&:metadata).map { |m| m['deleted_char'] }.compact.join
  end
  
  def self.analyze_divergence_reason(seq, note_id)
    # Check if user viewed another note around divergence time
    interaction = Interaction.find_by(sequence_number: seq)
    return nil unless interaction
    
    view_events = Event.where(
      event_type: 'note_viewed',
      note_id: note_id
    ).where(
      'timestamp BETWEEN ? AND ?',
      interaction.timestamp - 30.seconds,
      interaction.timestamp + 30.seconds
    )
    
    if view_events.exists?
      viewed_note = view_events.first.note
      "Viewed #{viewed_note.title} and changed direction"
    else
      "Self-correction"
    end
  end
end

# Generate migration
