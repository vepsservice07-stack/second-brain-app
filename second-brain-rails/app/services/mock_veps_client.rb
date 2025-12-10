# Mock VEPS Client - Simulates temporal ordering until real VEPS is ready
class MockVepsClient
  # Simulates submitting an event to VEPS
  def self.submit_event(event_data)
    {
      sequence_number: generate_sequence_number,
      vector_clock: generate_vector_clock,
      proof_hash: generate_proof_hash(event_data),
      timestamp_ms: (Time.now.to_f * 1000).to_i
    }
  end
  
  # Simulates submitting a rhythm event (structural, not keystrokes)
  def self.submit_rhythm_event(note_id:, event_type:, bpm: nil, duration_ms: nil)
    {
      sequence_number: generate_sequence_number,
      event_type: event_type, # 'flow_start', 'pause', 'burst', 'flow_end'
      note_id: note_id,
      bpm: bpm,
      duration_ms: duration_ms,
      timestamp_ms: (Time.now.to_f * 1000).to_i,
      proof_hash: generate_proof_hash({note_id: note_id, type: event_type})
    }
  end
  
  # Check causality between two events
  def self.check_causality(event_a_seq, event_b_seq)
    if event_a_seq < event_b_seq
      'happened-before'
    elsif event_a_seq > event_b_seq
      'happened-after'
    else
      'concurrent'
    end
  end
  
  private
  
  def self.generate_sequence_number
    # Simulates VEPS sub-50ms precision
    # In production, this comes from VEPS
    (Time.now.to_f * 1000).to_i
  end
  
  def self.generate_vector_clock
    # Simplified vector clock
    {
      node_id: 'node_1',
      counter: rand(1000..9999)
    }
  end
  
  def self.generate_proof_hash(data)
    # Simulates cryptographic proof
    Digest::SHA256.hexdigest(data.to_json + Time.now.to_s)[0..15]
  end
end
