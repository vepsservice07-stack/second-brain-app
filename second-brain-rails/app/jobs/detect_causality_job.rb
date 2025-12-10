class DetectCausalityJob
  include Sidekiq::Job
  
  def perform(note_id)
    note = Note.find(note_id)
    
    # Extract concepts and embedding
    analyzer = SemanticAnalyzer.new(note)
    analyzer.extract_concepts
    analyzer.get_embedding
    
    # Find potentially causal notes (created before this one)
    potential_causes = Note.active
      .where('sequence_number < ?', note.sequence_number)
      .where('created_at > ?', 30.days.ago)
      .order(sequence_number: :desc)
      .limit(100)
    
    # Calculate causal strength with each
    potential_causes.each do |cause|
      calculator = CausalStrengthCalculator.new(cause, note)
      strength = calculator.calculate
      
      Rails.logger.info("Causal strength: #{cause.id} → #{note.id} = #{strength}")
    end
  end
end
