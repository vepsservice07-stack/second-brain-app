class ProfilesController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @profile = current_user.cognitive_profile
    @analytics = @profile.analytics
    @recent_notes = current_user.notes.order(updated_at: :desc).limit(10)
    @total_words = current_user.notes.sum { |n| n.content.to_s.split.length }
    
    # Generate insights
    analytics_service = CognitiveAnalytics.new(current_user)
    @insights = analytics_service.generate_insights
  end
end
