# Extracts rich semantic field from interaction history
# This is the "right brain" - fuzzy, associative, emotional
class SemanticFieldExtractor
  class << self
    def extract(note_id, up_to_sequence: nil)
      interactions = fetch_interactions(note_id, up_to_sequence)
      
      return nil if interactions.empty?
      
      {
        note_id: note_id,
        sequence: up_to_sequence,
        text: EventStore.rebuild(note_id, up_to_sequence),
        rhythm: extract_rhythm(interactions),
        associations: extract_associations(note_id, interactions),
        emotional_valence: extract_valence(interactions),
        concept_drift: extract_drift(note_id, interactions),
        contextual_influences: extract_influences(note_id, interactions),
        cognitive_state: infer_cognitive_state(interactions),
        timestamp: Time.now
      }
    end
    
    private
    
    def fetch_interactions(note_id, up_to_sequence)
      query = Interaction.where(note_id: note_id).order(:sequence_number)
      query = query.where('sequence_number <= ?', up_to_sequence) if up_to_sequence
      query.to_a
    end
    
    def extract_rhythm(interactions)
      # Analyze pause patterns, velocity changes, deletion frequency
      pauses = []
      velocities = []
      deletions = 0
      
      interactions.each_cons(2) do |i1, i2|
        pause = (i2.created_at - i1.created_at).to_f
        velocity = 1.0 / [pause, 0.01].max
        
        pauses << pause
        velocities << velocity
        deletions += 1 if i2.data['operation'] == 'delete'
      end
      
      {
        avg_pause: pauses.sum / [pauses.length, 1].max,
        max_pause: pauses.max || 0,
        avg_velocity: velocities.sum / [velocities.length, 1].max,
        velocity_variance: calculate_variance(velocities),
        deletion_rate: deletions.to_f / [interactions.length, 1].max,
        flow_detected: detect_flow(velocities)
      }
    end
    
    def extract_associations(note_id, interactions)
      # What notes were viewed recently?
      start_time = interactions.first&.created_at || Time.now - 1.hour
      
      recent_views = Interaction
        .where(interaction_type: 'note_view')
        .where('created_at >= ? AND created_at <= ?', 
               start_time - 30.minutes, 
               interactions.last&.created_at || Time.now)
        .where.not(note_id: note_id)
        .pluck(:data)
        .map { |d| d['viewed_note_id'] }
        .compact
        .uniq
      
      recent_views.map do |viewed_id|
        viewed_note = Note.find_by(id: viewed_id)
        next unless viewed_note
        
        {
          note_id: viewed_id,
          title: viewed_note.title,
          viewed_at: viewed_note.interactions
            .where(interaction_type: 'note_view')
            .where('created_at >= ?', start_time - 30.minutes)
            .first&.created_at
        }
      end.compact
    end
    
    def extract_valence(interactions)
      # Infer emotional state from typing patterns
      rhythm = extract_rhythm(interactions)
      
      # High velocity + low deletions = confident
      # Low velocity + high deletions = uncertain
      # High velocity + high deletions = editing/refining
      
      confidence_score = (1.0 - rhythm[:deletion_rate]) * 
                        [rhythm[:avg_velocity] / 10.0, 1.0].min
      
      certainty = case rhythm[:avg_velocity]
                  when 0..3 then :very_low
                  when 3..5 then :low
                  when 5..8 then :medium
                  when 8..12 then :high
                  else :very_high
                  end
      
      {
        confidence: (confidence_score * 100).round(2),
        certainty: certainty,
        flow_state: rhythm[:flow_detected],
        hesitation_detected: rhythm[:max_pause] > 4.0,
        editing_mode: rhythm[:deletion_rate] > 0.15
      }
    end
    
    def extract_drift(note_id, interactions)
      # How concepts evolved during writing
      return [] if interactions.length < 50
      
      snapshots = []
      interactions.each_slice(50) do |chunk|
        seq = chunk.last.sequence_number
        content = EventStore.rebuild(note_id, seq)
        
        snapshots << {
          sequence: seq,
          content: content,
          word_count: content.split.length,
          unique_words: content.downcase.split.uniq.length
        }
      end
      
      # Calculate semantic drift between snapshots
      snapshots.each_cons(2).map do |before, after|
        {
          from_sequence: before[:sequence],
          to_sequence: after[:sequence],
          word_count_delta: after[:word_count] - before[:word_count],
          vocabulary_growth: after[:unique_words] - before[:unique_words],
          drift_magnitude: calculate_semantic_distance(before[:content], after[:content])
        }
      end
    end
    
    def extract_influences(note_id, interactions)
      # Find causal influences from viewed notes
      influences = []
      
      interactions.each_with_index do |interaction, idx|
        next unless interaction.interaction_type == 'keystroke'
        
        # Look back 5 minutes for note views
        recent_views = interactions[0...idx]
          .select { |i| i.interaction_type == 'note_view' }
          .select { |i| (interaction.created_at - i.created_at) < 300 }
        
        recent_views.each do |view|
          influences << {
            sequence: interaction.sequence_number,
            influenced_by: view.data['viewed_note_id'],
            time_delta: (interaction.created_at - view.created_at).to_f,
            confidence: calculate_influence_confidence(interaction, view)
          }
        end
      end
      
      influences
    end
    
    def infer_cognitive_state(interactions)
      rhythm = extract_rhythm(interactions)
      valence = extract_valence(interactions)
      
      # Cognitive state inference
      if rhythm[:flow_detected]
        :flow
      elsif valence[:hesitation_detected]
        :contemplating
      elsif valence[:editing_mode]
        :refining
      elsif rhythm[:avg_velocity] > 8
        :streaming
      elsif rhythm[:avg_velocity] < 3
        :stuck
      else
        :normal
      end
    end
    
    # Helper methods
    
    def calculate_variance(values)
      return 0 if values.empty?
      mean = values.sum / values.length.to_f
      variance = values.sum { |v| (v - mean) ** 2 } / values.length.to_f
      Math.sqrt(variance)
    end
    
    def detect_flow(velocities)
      return false if velocities.length < 10
      
      # Flow = sustained high velocity with low variance
      recent = velocities.last(10)
      avg = recent.sum / recent.length.to_f
      variance = calculate_variance(recent)
      
      avg > 8.0 && variance < 2.0
    end
    
    def calculate_semantic_distance(text1, text2)
      # Simple Jaccard distance for now
      # Could be upgraded to TF-IDF cosine similarity
      words1 = text1.downcase.split.to_set
      words2 = text2.downcase.split.to_set
      
      intersection = (words1 & words2).length
      union = (words1 | words2).length
      
      return 0 if union == 0
      1.0 - (intersection.to_f / union)
    end
    
    def calculate_influence_confidence(keystroke, view)
      # Simple heuristic: closer in time = higher confidence
      time_delta = (keystroke.created_at - view.created_at).to_f
      
      # Decay function: e^(-t/300) where t in seconds
      Math.exp(-time_delta / 300.0)
    end
  end
end
