module Api
  module V1
    class NotesController < BaseController
      before_action :set_note, only: [:show, :update, :destroy]
      
      # GET /api/v1/notes
      def index
        @notes = Note.active.order(updated_at: :desc).limit(100)
        
        render_json(
          notes: @notes.map { |note| note_json(note) },
          total: @notes.count
        )
      end
      
      # GET /api/v1/notes/:id
      def show
        render_json(note: note_json(@note, include_content: true))
      end
      
      # POST /api/v1/notes
      def create
        @note = Note.new(note_params)
        
        if @note.save
          render_json(note: note_json(@note, include_content: true), status: :created)
        else
          render_error(@note.errors.full_messages.join(', '))
        end
      end
      
      # PATCH /api/v1/notes/:id
      def update
        if @note.update(note_params)
          render_json(note: note_json(@note, include_content: true))
        else
          render_error(@note.errors.full_messages.join(', '))
        end
      end
      
      # DELETE /api/v1/notes/:id
      def destroy
        @note.soft_delete
        render_json(message: 'Note deleted', note_id: @note.id)
      end
      
      # GET /api/v1/notes/search?q=query
      def search
        query = params[:q]
        
        if query.present?
          @notes = Note.active.search_by_content(query).limit(50)
          render_json(
            notes: @notes.map { |note| note_json(note) },
            query: query,
            total: @notes.count
          )
        else
          render_error('Query parameter required', status: :bad_request)
        end
      end
      
      private
      
      def set_note
        @note = Note.active.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error('Note not found', status: :not_found)
      end
      
      def note_params
        params.require(:note).permit(:title, :content, tag_ids: [])
      end
      
      def note_json(note, include_content: false)
        json = {
          id: note.id,
          title: note.title,
          sequence_number: note.sequence_number,
          tag_ids: note.tag_ids,
          wiki_links: note.wiki_links,
          created_at: note.created_at.iso8601,
          updated_at: note.updated_at.iso8601
        }
        
        json[:content] = note.content if include_content
        json
      end
    end
  end
end
