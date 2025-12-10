class Note < ApplicationRecord
  belongs_to :user
  has_many :rhythm_events, dependent: :destroy
  
  validates :title, presence: true
  validates :content, presence: true
  
  # LEFT BRAIN: Analytical features
  def word_count
    content.to_s.split.length
  end
  
  def sentence_count
    content.to_s.scan(/[.!?]+/).length
  end
  
  def reading_time_minutes
    ((word_count.to_f / 200) * 60).round
  end
  
  # Detect thinking structure (LEFT BRAIN)
  def detect_structure
    content_lower = content.to_s.downcase
    
    structures = [
      { name: 'Logical Argument', emoji: '🎯', keywords: ['because', 'therefore', 'thus', 'hence'] },
      { name: 'Causal Chain', emoji: '⛓️', keywords: ['leads to', 'causes', 'results in'] },
      { name: 'Problem-Solution', emoji: '🔧', keywords: ['problem', 'solution', 'fix', 'resolve'] },
      { name: 'Personal Insight', emoji: '💭', keywords: ['feel', 'think', 'believe', 'realize'] },
      { name: 'Narrative Arc', emoji: '📖', keywords: ['then', 'next', 'finally', 'began'] }
    ]
    
    best_match = { name: 'Free Thought', emoji: '✨', score: 0 }
    
    structures.each do |structure|
      score = structure[:keywords].count { |kw| content_lower.include?(kw) }
      best_match = structure.merge(score: score) if score > best_match[:score]
    end
    
    best_match
  end
  
  # RIGHT BRAIN: Rhythm features
  def rhythm_signature
    RhythmEvent.calculate_signature(id)
  end
  
  def has_rhythm_data?
    rhythm_events.exists?
  end
  
  def spark_moments
    rhythm_events.sparks.ordered
  end
  
  # Generate mock rhythm data for existing notes (until real data arrives)
  def generate_mock_rhythm!
    return if has_rhythm_data?
    
    # Simulate a writing session with rhythm
    base_time = created_at.to_time.to_i * 1000
    events_data = []
    
    # Flow start
    events_data << {
      event_type: RhythmEvent::FLOW_START,
      bpm: rand(60..80),
      timestamp_ms: base_time
    }
    
    # Some flow periods with pauses
    current_time = base_time
    3.times do |i|
      # Flow period
      current_time += rand(30000..60000) # 30-60 seconds
      events_data << {
        event_type: RhythmEvent::FLOW_START,
        bpm: rand(65..85),
        timestamp_ms: current_time
      }
      
      # Pause (potential spark)
      if rand < 0.4 # 40% chance of pause
        current_time += rand(3000..8000) # 3-8 second pause
        events_data << {
          event_type: RhythmEvent::PAUSE,
          duration_ms: rand(3000..8000),
          timestamp_ms: current_time
        }
        
        # Burst after pause (breakthrough)
        if rand < 0.6 # 60% chance of burst after pause
          current_time += 1000
          events_data << {
            event_type: RhythmEvent::BURST,
            bpm: rand(95..120),
            timestamp_ms: current_time
          }
        end
      end
    end
    
    # Flow end
    current_time += rand(20000..40000)
    events_data << {
      event_type: RhythmEvent::FLOW_END,
      bpm: rand(50..70),
      timestamp_ms: current_time
    }
    
    # Submit to mock VEPS and create events
    events_data.each do |event_data|
      veps_response = MockVepsClient.submit_rhythm_event(
        note_id: id,
        event_type: event_data[:event_type],
        bpm: event_data[:bpm],
        duration_ms: event_data[:duration_ms]
      )
      
      rhythm_events.create!(
        sequence_number: veps_response[:sequence_number],
        event_type: event_data[:event_type],
        bpm: event_data[:bpm],
        duration_ms: event_data[:duration_ms],
        timestamp_ms: event_data[:timestamp_ms],
        proof_hash: veps_response[:proof_hash],
        vector_clock: veps_response[:vector_clock]
      )
    end
  end
end
