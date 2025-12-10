class TimeMachineController < ApplicationController
  def show
    @note = Note.find(params[:note_id])
    @sequence = params[:sequence]&.to_i
    
    if @sequence
      # Show content at specific sequence
      @content_at_sequence = @note.content_at_sequence(@sequence)
      @current_content = @note.content
    else
      # Show current content
      @content_at_sequence = @note.content
      @current_content = @note.content
    end
    
    # Get all interaction sequences for timeline
    @sequences = Interaction.for_note(@note.id)
      .select(:sequence_number, :timestamp, :interaction_type)
      .ordered
      .group_by { |i| (i.sequence_number / 100) * 100 }  # Group by 100s
  end
end
