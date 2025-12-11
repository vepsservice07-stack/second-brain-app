class VepsController < ApplicationController
  before_action :authenticate_user!
  
  def status
    @veps_healthy = VepsClient.healthy?
    @total_events = RhythmEvent.count
    @notes_with_rhythm = Note.joins(:rhythm_events).distinct.count
    @recent_events = RhythmEvent.order(created_at: :desc).limit(10)
  end
end
