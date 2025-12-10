class TimeTravelController < ApplicationController
  def index
    @note = Note.find(params[:note_id])
    
    # Get all versions of this note from the immutable log
    # For now, we'll show edit history via updated_at
    # In full VEPS integration, this would query the ledger
    @timeline = build_timeline(@note)
  end
  
  def show
    @note = Note.find(params[:note_id])
    @sequence = params[:sequence].to_i
    
    # In full VEPS: query ledger for state at this sequence
    # For now: show current state with sequence marker
    @state_at_sequence = @note
  end
  
  private
  
  def build_timeline(note)
    # Timeline of all events related to this note
    events = []
    
    # Note creation
    events << {
      type: 'created',
      sequence: note.sequence_number,
      timestamp: note.created_at,
      note: note
    }
    
    # Causal inputs (what influenced this)
    note.caused_by_notes.each do |cause|
      events << {
        type: 'influenced_by',
        sequence: cause.sequence_number,
        timestamp: cause.created_at,
        note: cause
      }
    end
    
    # Causal outputs (what this influenced)
    note.influenced_notes.each do |effect|
      events << {
        type: 'influenced',
        sequence: effect.sequence_number,
        timestamp: effect.created_at,
        note: effect
      }
    end
    
    events.sort_by { |e| e[:sequence] || 0 }
  end
end
