class CognitiveProfile < ApplicationRecord
  belongs_to :user
  
  store_accessor :patterns,
    :preferred_structures,
    :peak_hours
  
  def analytics
    {
      total_notes: total_notes_count || 0,
      avg_velocity: avg_velocity&.round(2),
      avg_confidence: avg_confidence&.round(2),
      peak_hours: peak_hours || [],
      preferred_structures: preferred_structures || []
    }
  end
end
