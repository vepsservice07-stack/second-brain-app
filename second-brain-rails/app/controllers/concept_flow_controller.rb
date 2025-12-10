class ConceptFlowController < ApplicationController
  def show
    @concept = params[:concept]
    
    # Find all notes containing this concept
    @notes_with_concept = Note.active
      .where("extracted_concepts @> ?", [@concept].to_json)
      .order(:sequence_number)
    
    # Build the flow: how this concept moved through notes
    @flow = build_concept_flow(@notes_with_concept)
  end
  
  private
  
  def build_concept_flow(notes)
    notes.map do |note|
      {
        note: note,
        sequence: note.sequence_number,
        timestamp: note.created_at,
        influenced_by: note.caused_by_notes.where(
          "extracted_concepts @> ?", [@concept].to_json
        ),
        influenced: note.influenced_notes.where(
          "extracted_concepts @> ?", [@concept].to_json
        )
      }
    end
  end
end
