class CausalStrengthCalculator
  def initialize(cause_note, effect_note)
    @cause = cause_note
    @effect = effect_note
  end
  
  # Calculate overall causal strength (0.0 to 1.0)
  def calculate
    return 0.0 unless valid_causality?
    
    temporal = temporal_proximity
    semantic = semantic_similarity
    contextual = contextual_overlap
    
    # Weighted combination
    strength = (temporal * 0.3) + (semantic * 0.5) + (contextual * 0.2)
    
    # Store the link if strong enough
    if strength > 0.3
      create_causal_link(strength)
    end
    
    strength
  end
  
  private
  
  def valid_causality?
    return false unless @cause && @effect
    return false unless @cause.sequence_number && @effect.sequence_number
    
    # Cause must come before effect
    @cause.sequence_number < @effect.sequence_number
  end
  
  # How close in time/sequence were they?
  def temporal_proximity
    seq_diff = @effect.sequence_number - @cause.sequence_number
    
    # Exponential decay: closer = stronger
    # Within 100 sequences = 1.0
    # 1000 sequences = ~0.37
    # 10000 sequences = ~0.0
    Math.exp(-seq_diff / 100.0).clamp(0.0, 1.0)
  end
  
  # How semantically similar are they?
  def semantic_similarity
    SemanticAnalyzer.new(@cause).similarity_with(@effect)
  end
  
  # Was cause note being viewed when effect was created?
  def contextual_overlap
    # Check if there's a view event for cause note
    # around the time effect was created
    view_events = Event.where(
      event_type: 'note_viewed',
      note_id: @cause.id
    ).where(
      'timestamp BETWEEN ? AND ?',
      @effect.created_at - 5.minutes,
      @effect.created_at
    )
    
    view_events.exists? ? 1.0 : 0.0
  end
  
  def create_causal_link(strength)
    CausalLink.find_or_create_by!(
      cause_note_id: @cause.id,
      effect_note_id: @effect.id
    ) do |link|
      link.strength = strength
      link.context = "Auto-detected via semantic analysis"
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("Could not create causal link: #{e.message}")
  end
end
