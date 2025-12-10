# frozen_string_literal: true

module VepsEventable
  extend ActiveSupport::Concern
  
  included do
    after_create :submit_created_event
    after_update :submit_updated_event, if: :should_submit_update?
    before_destroy :submit_deleted_event
  end
  
  private
  
  def submit_created_event
    submit_veps_event("#{model_name.singular}_created")
  end
  
  def submit_updated_event
    submit_veps_event("#{model_name.singular}_updated")
  end
  
  def submit_deleted_event
    submit_veps_event("#{model_name.singular}_deleted")
  end
  
  def submit_veps_event(event_type)
    return unless should_submit_to_veps?
    
    result = Veps::Client.submit_event(
      event_type: event_type,
      actor: event_actor,
      evidence: event_evidence
    )
    
    if result[:success]
      update_column(:sequence_number, result[:sequence_number]) if respond_to?(:sequence_number)
      Rails.logger.info("VEPS event submitted: #{event_type} - Sequence: #{result[:sequence_number]}")
    else
      Rails.logger.error("VEPS submission failed: #{result[:error]}")
    end
  rescue StandardError => e
    Rails.logger.error("VEPS submission error: #{e.message}")
  end
  
  def should_submit_to_veps?
    true
  end
  
  def should_submit_update?
    saved_changes.present? && !saved_changes.keys.include?('updated_at')
  end
  
  def event_actor
    {
      id: user_id || "system",
      name: "User #{user_id || 'System'}",
      type: "user"
    }
  end
  
  def event_evidence
    attributes.except('created_at', 'updated_at', 'deleted_at')
  end
end
