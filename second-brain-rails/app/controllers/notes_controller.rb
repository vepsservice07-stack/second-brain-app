class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  
  def index
    @notes = current_user.notes.order(updated_at: :desc)
    
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @notes = @notes.where("title LIKE ? OR content LIKE ?", search_term, search_term)
    end
    
    case params[:filter]
    when 'today'
      @notes = @notes.where('created_at >= ?', Time.zone.now.beginning_of_day)
    when 'week'
      @notes = @notes.where('created_at >= ?', 1.week.ago)
    when 'month'
      @notes = @notes.where('created_at >= ?', 1.month.ago)
    end
  end
  
  def show
    # Generate mock rhythm if needed (for demo)
    @note.generate_mock_rhythm! unless @note.has_rhythm_data?
    @rhythm_signature = @note.rhythm_signature
    @spark_moments = @note.spark_moments
  end
  
  def new
    @note = current_user.notes.build
  end
  
  def create
    @note = current_user.notes.build(note_params)
    
    if @note.save
      redirect_to @note, notice: '🎉 Note created! Your rhythm has been captured.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if @note.update(note_params)
      redirect_to @note, notice: '✨ Note updated!'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note.destroy
    redirect_to notes_path, notice: 'Note deleted. 🗑️'
  end
  
  # API endpoint for receiving rhythm data from frontend
  def receive_rhythm
    @note = current_user.notes.find(params[:id])
    
    rhythm_data = params[:rhythm_data]
    
    rhythm_data.each do |event_data|
      veps_response = MockVepsClient.submit_rhythm_event(
        note_id: @note.id,
        event_type: event_data[:event_type],
        bpm: event_data[:bpm],
        duration_ms: event_data[:duration_ms]
      )
      
      @note.rhythm_events.create!(
        sequence_number: veps_response[:sequence_number],
        event_type: event_data[:event_type],
        bpm: event_data[:bpm],
        duration_ms: event_data[:duration_ms],
        timestamp_ms: veps_response[:timestamp_ms],
        proof_hash: veps_response[:proof_hash],
        vector_clock: veps_response[:vector_clock]
      )
    end
    
    head :ok
  end
  
  private
  
  def set_note
    @note = current_user.notes.find(params[:id])
  end
  
  def note_params
    params.require(:note).permit(:title, :content)
  end
end
