class SemanticUndo
  def initialize(note)
    @note = note
  end
  
  # Find undo points (not just char-by-char)
  def find_undo_points
    interactions = Interaction.for_note(@note.id).ordered
    undo_points = []
    
    # 1. Pause boundaries (thought boundaries)
    interactions.each do |interaction|
      if interaction.thinking_pause?
        undo_points << {
          type: 'pause_boundary',
          sequence: interaction.sequence_number,
          label: "Undo to before #{(interaction.duration_ms/1000.0).round(1)}s pause",
          timestamp: interaction.timestamp
        }
      end
    end
    
    # 2. View event boundaries (causal boundaries)
    @note.events.where(event_type: 'note_viewed').each do |view_event|
      text_after = text_added_after_sequence(view_event.sequence_number)
      
      undo_points << {
        type: 'causal_boundary',
        sequence: view_event.sequence_number,
        label: "Undo to before viewing '#{view_event.metadata['viewed_note_title']}'",
        affected_text: text_after,
        timestamp: view_event.timestamp
      }
    end
    
    # 3. Concept boundaries (semantic units)
    concepts = extract_concepts_with_sequences
    concepts.each do |concept|
      undo_points << {
        type: 'concept_boundary',
        sequence: concept[:first_sequence],
        label: "Undo concept: '#{concept[:name]}'",
        affected_text: concept[:text],
        timestamp: concept[:timestamp]
      }
    end
    
    # Sort by sequence (most recent first)
    undo_points.sort_by { |p| -p[:sequence] }.first(20)
  end
  
  # Undo to specific boundary
  def undo_to(boundary_sequence)
    # Rebuild content up to boundary
    EventStore.rebuild(@note.id, up_to_sequence: boundary_sequence)
  end
  
  # Redo (replay forward)
  def redo_to(target_sequence)
    EventStore.rebuild(@note.id, up_to_sequence: target_sequence)
  end
  
  private
  
  def text_added_after_sequence(seq)
    interactions = Interaction.for_note(@note.id)
      .where('sequence_number > ?', seq)
      .ordered
      .limit(50)
    
    interactions.keystrokes.map(&:char).join
  end
  
  def extract_concepts_with_sequences
    # Use existing concept extraction
    concepts = @note.extracted_concepts || []
    
    concepts.map do |concept|
      # Find first sequence where concept appeared
      interactions = Interaction.for_note(@note.id).ordered.keystrokes
      
      # Search for concept in interaction stream
      chars = interactions.map(&:char)
      concept_chars = concept.chars
      
      first_index = (0..chars.length - concept_chars.length).find do |i|
        chars[i, concept_chars.length] == concept_chars
      end
      
      if first_index
        first_interaction = interactions[first_index]
        {
          name: concept,
          first_sequence: first_interaction.sequence_number,
          text: concept,
          timestamp: first_interaction.timestamp
        }
      end
    end.compact
  end
end
