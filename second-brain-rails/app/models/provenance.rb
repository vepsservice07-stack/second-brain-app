class Provenance
  def initialize(note)
    @note = note
  end
  
  # Prove when this idea was recorded
  def timestamp_proof
    {
      sequence_number: @note.sequence_number,
      created_at: @note.created_at,
      updated_at: @note.updated_at,
      causal_position: causal_position,
      immutable: true  # From VEPS ledger
    }
  end
  
  # Where does this sit in the causal order?
  def causal_position
    before_count = Note.where('sequence_number < ?', @note.sequence_number).count
    after_count = Note.where('sequence_number > ?', @note.sequence_number).count
    
    {
      notes_before: before_count,
      notes_after: after_count,
      percentile: (before_count.to_f / (before_count + after_count + 1) * 100).round(2)
    }
  end
  
  # What existed when I wrote this?
  def context_at_creation
    Note.active
      .where('sequence_number < ?', @note.sequence_number)
      .order(sequence_number: :desc)
      .limit(10)
  end
  
  # Audit trail
  def audit_trail
    {
      note_id: @note.id,
      sequence: @note.sequence_number,
      created: @note.created_at.iso8601,
      immutable_since: @note.created_at.iso8601,
      causal_dependencies: @note.caused_by_notes.pluck(:id, :sequence_number),
      verification: "Provable via VEPS ledger query"
    }
  end
end
