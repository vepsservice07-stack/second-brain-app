class EventStore
  class << self
    # Append event to store
    def append(note_id:, operation:, char: nil, position: nil, device_id: nil)
      # Submit to VEPS
      result = Veps::Client.submit_event(
        event_type: "interaction_#{operation}",
        actor: { id: device_id || 'system', type: 'user' },
        evidence: {
          note_id: note_id,
          operation: operation,
          char: char,
          position: position
        }
      )
      
      if result[:success]
        # Store locally
        Interaction.create!(
          note_id: note_id,
          interaction_type: operation,
          sequence_number: result[:sequence_number],
          char: char,
          position: position,
          device_id: result[:device_id],
          vector_clock: result[:vector_clock],
          previous_hash: result[:metadata][:previous_hash],
          timestamp: result[:timestamp]
        )
      end
      
      result
    end
    
    # Rebuild note content from events
    def rebuild(note_id, up_to_sequence: nil)
      # Check for recent snapshot
      snapshot = Snapshot.for_note(note_id)
        .where('sequence_number <= ?', up_to_sequence || Float::INFINITY)
        .order(sequence_number: :desc)
        .first
      
      # Start from snapshot or empty
      if snapshot
        content = snapshot.content
        from_sequence = snapshot.sequence_number + 1
      else
        content = ""
        from_sequence = 0
      end
      
      # Get events after snapshot
      events = Interaction.for_note(note_id)
        .where('sequence_number >= ?', from_sequence)
        .where('sequence_number <= ?', up_to_sequence || Float::INFINITY)
        .ordered
      
      # Apply events
      events.each do |event|
        content = apply_event(content, event)
      end
      
      content
    end
    
    # Apply single event to content
    def apply_event(content, event)
      case event.interaction_type
      when 'keystroke', 'insert'
        # Insert character at position
        position = [event.position || content.length, content.length].min
        content.insert(position, event.char || '')
        
      when 'delete', 'backspace'
        # Delete character at position
        position = event.position || content.length - 1
        content.slice!(position) if position >= 0 && position < content.length
        
      when 'paste'
        # Insert text at position
        position = event.position || content.length
        content.insert(position, event.metadata['text'] || '')
      end
      
      content
    end
    
    # Create snapshot for fast replay
    def create_snapshot(note_id)
      content = rebuild(note_id)
      sequence = Interaction.for_note(note_id).maximum(:sequence_number) || 0
      interaction_count = Interaction.for_note(note_id).count
      
      # Generate Merkle root for proof
      interactions = Interaction.for_note(note_id).ordered
      merkle_root = calculate_merkle_root(interactions)
      
      Snapshot.create!(
        note_id: note_id,
        sequence_number: sequence,
        content: content,
        interaction_count: interaction_count,
        merkle_root: merkle_root
      )
    end
    
    private
    
    def calculate_merkle_root(interactions)
      return nil if interactions.empty?
      
      hashes = interactions.map do |i|
        Digest::SHA256.hexdigest("#{i.sequence_number}#{i.char}#{i.timestamp}")
      end
      
      # Build tree
      while hashes.size > 1
        hashes = hashes.each_slice(2).map do |pair|
          Digest::SHA256.hexdigest(pair.join)
        end
      end
      
      hashes.first
    end
  end
end
