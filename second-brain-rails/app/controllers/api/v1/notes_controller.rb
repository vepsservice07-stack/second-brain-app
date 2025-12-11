module Api
  module V1
    class NotesController < BaseController
      before_action :set_note, only: [:show, :update, :destroy]
      
      def index
        @notes = current_user.notes.order(updated_at: :desc)
        render json: @notes.map { |n| note_summary(n) }
      end
      
      def show
        @note.generate_mock_rhythm! unless @note.has_rhythm_data?
        render json: note_detail(@note)
      end
      
      def create
        @note = current_user.notes.build(note_params)
        if @note.save
          render json: note_detail(@note), status: :created
        else
          render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        if @note.update(note_params)
          render json: note_detail(@note)
        else
          render json: { errors: @note.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @note.destroy
        head :no_content
      end
      
      private
      
      def set_note
        @note = current_user.notes.find(params[:id])
      end
      
      def note_params
        params.require(:note).permit(:title, :content)
      end
      
      def note_summary(note)
        {
          id: note.id,
          title: note.title,
          content: note.content.truncate(200),
          created_at: note.created_at,
          updated_at: note.updated_at,
          word_count: note.word_count,
          structure: note.detect_structure
        }
      end
      
      def note_detail(note)
        note_summary(note).merge({
          content: note.content,
          sentence_count: note.sentence_count,
          reading_time_minutes: note.reading_time_minutes,
          rhythm_signature: note.rhythm_signature,
          rhythm_events: note.rhythm_events.ordered.map { |e|
            { event_type: e.event_type, bpm: e.bpm, duration_ms: e.duration_ms }
          }
        })
      end
    end
  end
end
