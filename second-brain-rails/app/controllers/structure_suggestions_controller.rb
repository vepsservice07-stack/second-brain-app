class StructureSuggestionsController < ApplicationController
  # GET /notes/:note_id/structure_suggestions
  def show
    @note = Note.find(params[:note_id])
    
    # Get real-time structure suggestions
    suggestions = StructureSuggester.suggest(@note.id)
    
    if suggestions
      render json: suggestions
    else
      render json: { error: "Unable to analyze note" }, status: :unprocessable_entity
    end
  end
  
  # POST /notes/:note_id/apply_structure
  def apply
    @note = Note.find(params[:note_id])
    structure_type = params[:structure_type].to_sym
    modifications = params[:modifications] || {}
    
    result = StructureSuggester.apply_structure(
      @note.id,
      structure_type,
      user_modifications: modifications
    )
    
    render json: { 
      success: true,
      formatted_content: result
    }
  end
  
  # GET /notes/:note_id/semantic_field
  def semantic_field
    @note = Note.find(params[:note_id])
    field = SemanticFieldExtractor.extract(@note.id)
    
    render json: field
  end
end
