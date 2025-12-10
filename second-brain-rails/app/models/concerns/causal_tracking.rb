# frozen_string_literal: true

module CausalTracking
  extend ActiveSupport::Concern
  
  included do
    # Track what this note was reading/viewing when created
    has_many :causal_inputs, class_name: 'CausalLink', foreign_key: 'effect_note_id'
    has_many :caused_by_notes, through: :causal_inputs, source: :cause_note
    
    # Track what this note influenced
    has_many :causal_outputs, class_name: 'CausalLink', foreign_key: 'cause_note_id'
    has_many :influenced_notes, through: :causal_outputs, source: :effect_note
    
    after_create :record_causal_context
  end
  
  # What was I reading when I wrote this?
  def causal_ancestors(depth: 3)
    return [] if depth == 0
    
    direct = caused_by_notes.active
    indirect = direct.flat_map { |n| n.causal_ancestors(depth: depth - 1) }
    
    (direct + indirect).uniq.sort_by(&:sequence_number)
  end
  
  # What did this influence?
  def causal_descendants(depth: 3)
    return [] if depth == 0
    
    direct = influenced_notes.active
    indirect = direct.flat_map { |n| n.causal_descendants(depth: depth - 1) }
    
    (direct + indirect).uniq.sort_by(&:sequence_number)
  end
  
  # The causal chain: ancestor -> this -> descendants
  def causal_chain
    {
      ancestors: causal_ancestors(depth: 2),
      self: self,
      descendants: causal_descendants(depth: 2)
    }
  end
  
  private
  
  def record_causal_context
    # Record what notes were recently viewed
    # This creates the causal graph automatically
    # Implementation: check session/cookies for recent note views
  end
end
