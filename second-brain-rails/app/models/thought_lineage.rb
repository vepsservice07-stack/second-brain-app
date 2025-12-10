class ThoughtLineage
  def initialize(note)
    @note = note
  end
  
  # How did I arrive at this thought?
  def trace_origins
    origins = []
    queue = [@note]
    seen = Set.new([@note.id])
    
    while queue.any? && origins.count < 20
      current = queue.shift
      
      current.caused_by_notes.each do |cause|
        next if seen.include?(cause.id)
        
        origins << {
          note: cause,
          distance: origins.count + 1,
          path: "trace this path implementation"
        }
        
        seen.add(cause.id)
        queue << cause
      end
    end
    
    origins.sort_by { |o| o[:note].sequence_number }
  end
  
  # What did this thought lead to?
  def trace_impact
    impacts = []
    queue = [@note]
    seen = Set.new([@note.id])
    
    while queue.any? && impacts.count < 20
      current = queue.shift
      
      current.influenced_notes.each do |effect|
        next if seen.include?(effect.id)
        
        impacts << {
          note: effect,
          distance: impacts.count + 1
        }
        
        seen.add(effect.id)
        queue << effect
      end
    end
    
    impacts.sort_by { |i| i[:note].sequence_number }
  end
  
  # The full story: origin -> current -> impact
  def full_lineage
    {
      origins: trace_origins,
      current: @note,
      impacts: trace_impact,
      sequence_span: sequence_span
    }
  end
  
  private
  
  def sequence_span
    all_notes = trace_origins.map { |o| o[:note] } + [@note] + trace_impact.map { |i| i[:note] }
    sequences = all_notes.map(&:sequence_number).compact
    
    return nil if sequences.empty?
    
    {
      min: sequences.min,
      max: sequences.max,
      span: sequences.max - sequences.min
    }
  end
end
