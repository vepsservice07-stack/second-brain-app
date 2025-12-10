class ConvergenceAnalyzer
  # Find notes that converge on similar ideas from different origins
  def self.find_convergent_thoughts(limit: 10)
    # Notes with similar content but different causal ancestors
    # This identifies independent arrivals at similar conclusions
    
    Note.active
      .select('notes.*, COUNT(DISTINCT causal_links.cause_note_id) as ancestor_count')
      .joins('LEFT JOIN causal_links ON notes.id = causal_links.effect_note_id')
      .group('notes.id')
      .having('COUNT(DISTINCT causal_links.cause_note_id) > 1')
      .order('ancestor_count DESC')
      .limit(limit)
  end
  
  # Detect when multiple thought streams merge
  def self.find_synthesis_points
    # Notes that have multiple causal inputs from different clusters
    Note.active
      .joins(:causal_inputs)
      .group('notes.id')
      .having('COUNT(DISTINCT causal_links.cause_note_id) >= 2')
      .includes(:caused_by_notes)
  end
  
  # The "aha!" moments - where separate threads connected
  def self.find_breakthroughs
    synthesis_points = find_synthesis_points
    
    synthesis_points.select do |note|
      ancestors = note.caused_by_notes
      # Check if ancestors are from different "clusters"
      # (for now: created more than 1 day apart)
      next false if ancestors.count < 2
      
      timestamps = ancestors.map(&:created_at).sort
      time_gap = timestamps.last - timestamps.first
      
      time_gap > 1.day
    end
  end
end
