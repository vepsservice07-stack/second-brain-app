class RhythmEvent < ApplicationRecord
  belongs_to :note
  
  # Event types representing cognitive states
  FLOW_START = 'flow_start'
  PAUSE = 'pause'
  BURST = 'burst'
  FLOW_END = 'flow_end'
  CONTEMPLATION = 'contemplation'
  
  validates :event_type, inclusion: { 
    in: [FLOW_START, PAUSE, BURST, FLOW_END, CONTEMPLATION] 
  }
  
  scope :ordered, -> { order(sequence_number: :asc) }
  scope :sparks, -> { where(event_type: [PAUSE, BURST]) }
  
  # Calculate rhythm signature for a note
  def self.calculate_signature(note_id)
    events = where(note_id: note_id).ordered
    return nil if events.empty?
    
    {
      avg_bpm: events.where.not(bpm: nil).average(:bpm)&.round || 0,
      spark_count: events.sparks.count,
      total_pauses_ms: events.where(event_type: PAUSE).sum(:duration_ms),
      has_breakthroughs: events.where(event_type: BURST).exists?
    }
  end
end
