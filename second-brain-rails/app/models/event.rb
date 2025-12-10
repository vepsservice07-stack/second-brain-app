class Event < ApplicationRecord
  belongs_to :note, optional: true
  belongs_to :user, optional: true
  
  # Event types
  TYPES = %w[
    note_created
    note_updated
    note_viewed
    note_deleted
    keystroke
    cursor_moved
    link_created
  ].freeze
  
  validates :event_type, presence: true, inclusion: { in: TYPES }
  validates :timestamp, presence: true
  
  scope :for_note, ->(note_id) { where(note_id: note_id) }
  scope :ordered, -> { order(sequence_number: :asc) }
  scope :recent, -> { order(timestamp: :desc) }
  
  # Submit to VEPS
  def self.submit_to_veps(event_type:, note: nil, payload: {})
    result = Veps::Client.submit_event(
      event_type: event_type,
      actor: { id: "system", name: "Second Brain", type: "system" },
      evidence: {
        note_id: note&.id,
        **payload
      }
    )
    
    if result[:success]
      create!(
        event_type: event_type,
        note_id: note&.id,
        sequence_number: result[:sequence_number],
        payload: payload,
        timestamp: Time.current,
        vector_clock: result[:vector_clock] || {}
      )
    else
      Rails.logger.error("VEPS submission failed: #{result[:error]}")
      nil
    end
  end
  
  # Get causal context (what was happening before this event)
  def causal_context(window: 100)
    Event.where('sequence_number < ? AND sequence_number > ?', 
                sequence_number, 
                sequence_number - window)
         .ordered
  end
  
  # What notes were being viewed when this was written?
  def concurrent_views
    return [] unless note_id
    
    Event.where(event_type: 'note_viewed')
         .where('timestamp BETWEEN ? AND ?', 
                timestamp - 5.minutes, 
                timestamp)
         .where.not(note_id: note_id)
         .pluck(:note_id)
         .uniq
  end
end
