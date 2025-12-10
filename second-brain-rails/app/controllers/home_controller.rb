class HomeController < ApplicationController
  def index
    @recent_notes = Note.active.order(updated_at: :desc).limit(5)
    @note_count = Note.active.count
    @tag_count = Tag.count
  end
end
