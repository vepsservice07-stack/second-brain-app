#!/bin/bash
set -e

echo "======================================"
echo "✨ Phase 5: Magic Features"
echo "======================================"
echo ""
echo "Adding the features that make Second Brain magical..."
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Step 1: Enhanced Cognitive Analytics
echo "Step 1: Creating Cognitive Analytics Dashboard..."
echo "======================================"

cat > app/services/cognitive_analytics.rb << 'RUBY'
# Analyzes your thinking patterns and provides insights
class CognitiveAnalytics
  def initialize(user)
    @user = user
    @notes = user.notes.order(created_at: :asc)
  end
  
  def generate_insights
    {
      productivity: analyze_productivity,
      thinking_style: analyze_thinking_style,
      content_evolution: analyze_content_evolution,
      peak_performance: analyze_peak_times,
      topic_distribution: analyze_topics,
      writing_velocity: analyze_velocity
    }
  end
  
  private
  
  def analyze_productivity
    by_day = @notes.group_by { |n| n.created_at.to_date }
    
    {
      total_notes: @notes.count,
      total_words: @notes.sum { |n| n.content.to_s.split.length },
      avg_note_length: (@notes.sum { |n| n.content.to_s.split.length } / [@notes.count, 1].max),
      most_productive_day: by_day.max_by { |_, notes| notes.count }&.first,
      current_streak: calculate_streak,
      notes_this_week: @notes.where('created_at > ?', 1.week.ago).count
    }
  end
  
  def analyze_thinking_style
    # Analyze content patterns to determine thinking style
    content = @notes.map(&:content).join(' ').downcase
    
    analytical_words = ['because', 'therefore', 'analyze', 'logic', 'reason']
    creative_words = ['imagine', 'create', 'story', 'metaphor', 'like']
    reflective_words = ['feel', 'think', 'realize', 'understand', 'aware']
    practical_words = ['do', 'make', 'build', 'solve', 'fix']
    
    scores = {
      analytical: analytical_words.count { |w| content.include?(w) },
      creative: creative_words.count { |w| content.include?(w) },
      reflective: reflective_words.count { |w| content.include?(w) },
      practical: practical_words.count { |w| content.include?(w) }
    }
    
    total = scores.values.sum
    return { primary: 'balanced', distribution: {} } if total.zero?
    
    {
      primary: scores.max_by { |_, v| v }&.first,
      distribution: scores.transform_values { |v| ((v.to_f / total) * 100).round }
    }
  end
  
  def analyze_content_evolution
    return {} if @notes.count < 2
    
    first_half = @notes.first(@notes.count / 2)
    second_half = @notes.last(@notes.count / 2)
    
    {
      avg_length_change: {
        before: first_half.sum { |n| n.content.to_s.split.length } / [first_half.count, 1].max,
        after: second_half.sum { |n| n.content.to_s.split.length } / [second_half.count, 1].max
      },
      frequency_change: {
        before: first_half.count,
        after: second_half.count
      }
    }
  end
  
  def analyze_peak_times
    by_hour = @notes.group_by { |n| n.created_at.hour }
    
    return { message: 'Not enough data yet' } if by_hour.empty?
    
    peak_hour = by_hour.max_by { |_, notes| notes.count }&.first
    
    {
      peak_hour: peak_hour,
      peak_time_range: "#{peak_hour}:00 - #{peak_hour + 1}:00",
      notes_at_peak: by_hour[peak_hour]&.count || 0,
      recommendation: generate_time_recommendation(peak_hour)
    }
  end
  
  def analyze_topics
    # Simple keyword extraction
    all_words = @notes.map { |n| n.content.to_s.downcase.split }.flatten
    word_freq = all_words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 if word.length > 4 }
    
    top_words = word_freq.sort_by { |_, count| -count }.take(10)
    
    {
      common_themes: top_words.map(&:first),
      unique_words: all_words.uniq.count,
      vocabulary_richness: (all_words.uniq.count.to_f / [all_words.count, 1].max * 100).round(1)
    }
  end
  
  def analyze_velocity
    return {} if @notes.count < 2
    
    time_spans = @notes.each_cons(2).map { |a, b| (b.created_at - a.created_at) / 3600 }
    avg_hours_between = time_spans.sum / time_spans.count
    
    {
      avg_hours_between_notes: avg_hours_between.round(1),
      pace: classify_pace(avg_hours_between)
    }
  end
  
  def calculate_streak
    return 0 if @notes.empty?
    
    streak = 1
    current_date = Date.today
    
    while @notes.any? { |n| n.created_at.to_date == current_date }
      streak += 1
      current_date -= 1.day
    end
    
    streak - 1
  end
  
  def generate_time_recommendation(hour)
    case hour
    when 0..5
      "Night owl! You're most creative in the quiet hours."
    when 6..11
      "Morning thinker! You capture ideas best early in the day."
    when 12..17
      "Afternoon focused! Peak productivity in the middle of the day."
    when 18..23
      "Evening reflective! You process thoughts best at day's end."
    end
  end
  
  def classify_pace(hours)
    case hours
    when 0..1
      "rapid (multiple notes per day)"
    when 1..12
      "active (daily thinker)"
    when 12..48
      "steady (regular reflection)"
    else
      "contemplative (deep, occasional thoughts)"
    end
  end
end
RUBY

echo "✓ Cognitive analytics service created"

# Step 2: Enhanced Profile Controller
echo ""
echo "Step 2: Updating profile with analytics..."
echo "======================================"

cat > app/controllers/profiles_controller.rb << 'RUBY'
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
RUBY

echo "✓ Profile controller updated"

# Step 3: Beautiful Analytics Dashboard View
echo ""
echo "Step 3: Creating beautiful analytics dashboard..."
echo "======================================"

cat > app/views/profiles/show.html.erb << 'HTML'
<div class="container-wide">
  <div class="mb-4">
    <h1>Your Cognitive Profile</h1>
    <p class="text-subtle">Understanding how you think</p>
  </div>
  
  <!-- Quick Stats Grid -->
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 3rem;">
    <div class="card text-center" style="background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%); color: white; border: none;">
      <h2 style="color: white; margin-bottom: 0.5rem;">
        <%= @insights[:productivity][:total_notes] %>
      </h2>
      <p style="color: rgba(255,255,255,0.9);">Notes Created</p>
    </div>
    
    <div class="card text-center" style="background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-light) 100%); color: white; border: none;">
      <h2 style="color: white; margin-bottom: 0.5rem;">
        <%= number_to_human(@insights[:productivity][:total_words]) %>
      </h2>
      <p style="color: rgba(255,255,255,0.9);">Words Written</p>
    </div>
    
    <div class="card text-center" style="background: linear-gradient(135deg, var(--color-success) 0%, #8AB09E 100%); color: white; border: none;">
      <h2 style="color: white; margin-bottom: 0.5rem;">
        <%= @insights[:productivity][:current_streak] %>
      </h2>
      <p style="color: rgba(255,255,255,0.9);">Day Streak</p>
    </div>
    
    <div class="card text-center">
      <h2 style="color: var(--color-primary); margin-bottom: 0.5rem;">
        <%= @insights[:productivity][:avg_note_length] %>
      </h2>
      <p class="text-subtle">Avg Words/Note</p>
    </div>
  </div>
  
  <!-- Thinking Style Analysis -->
  <div class="card mb-4">
    <h2 class="mb-3">🧠 Your Thinking Style</h2>
    
    <div style="margin-bottom: 2rem;">
      <h3 style="color: var(--color-accent); margin-bottom: 1rem;">
        Primary: <%= @insights[:thinking_style][:primary].to_s.titleize %>
      </h3>
      
      <div style="display: grid; gap: 1rem;">
        <% if @insights[:thinking_style][:distribution] %>
          <% @insights[:thinking_style][:distribution].sort_by { |_, v| -v }.each do |style, percentage| %>
            <div>
              <div class="flex-between mb-1">
                <span style="font-weight: 500;"><%= style.to_s.titleize %></span>
                <span class="text-subtle"><%= percentage %>%</span>
              </div>
              <div style="background: var(--color-bg); height: 8px; border-radius: 4px; overflow: hidden;">
                <div style="background: var(--color-primary); height: 100%; width: <%= percentage %>%; transition: width 0.6s var(--ease-smooth);"></div>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
    
    <div style="padding: 1.5rem; background: rgba(91, 124, 153, 0.05); border-radius: 8px;">
      <h4 class="mb-2">What this means:</h4>
      <% case @insights[:thinking_style][:primary] %>
      <% when :analytical %>
        <p class="text-subtle">You break down complex problems logically. You value clarity, reason, and structured thinking.</p>
      <% when :creative %>
        <p class="text-subtle">You think in metaphors and stories. You make unexpected connections and see possibilities.</p>
      <% when :reflective %>
        <p class="text-subtle">You process through introspection. You understand yourself and learn from experience.</p>
      <% when :practical %>
        <p class="text-subtle">You focus on action and solutions. You turn ideas into concrete outcomes.</p>
      <% else %>
        <p class="text-subtle">You have a balanced thinking style, drawing from multiple approaches as needed.</p>
      <% end %>
    </div>
  </div>
  
  <!-- Peak Performance Times -->
  <% if @insights[:peak_performance][:peak_hour] %>
    <div class="card mb-4">
      <h2 class="mb-3">⏰ Peak Performance</h2>
      
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem;">
        <div>
          <h3 style="color: var(--color-accent); margin-bottom: 0.5rem;">
            <%= @insights[:peak_performance][:peak_time_range] %>
          </h3>
          <p class="text-subtle">Your most productive time</p>
          <p style="margin-top: 1rem; font-size: 2rem; color: var(--color-primary);">
            <%= @insights[:peak_performance][:notes_at_peak] %> notes
          </p>
        </div>
        
        <div style="padding: 1.5rem; background: rgba(212, 165, 116, 0.1); border-radius: 8px; border-left: 3px solid var(--color-accent);">
          <p style="font-style: italic; color: var(--color-text);">
            <%= @insights[:peak_performance][:recommendation] %>
          </p>
        </div>
      </div>
    </div>
  <% end %>
  
  <!-- Writing Velocity -->
  <% if @insights[:writing_velocity][:pace] %>
    <div class="card mb-4">
      <h2 class="mb-3">📊 Writing Pattern</h2>
      
      <div style="display: flex; align-items: center; gap: 2rem; flex-wrap: wrap;">
        <div>
          <div class="text-subtle mb-1">Average time between notes</div>
          <h3 style="color: var(--color-primary);">
            <%= @insights[:writing_velocity][:avg_hours_between_notes] %> hours
          </h3>
        </div>
        
        <div style="flex: 1; min-width: 200px;">
          <div class="text-subtle mb-1">Your pace</div>
          <p style="font-size: 1.1rem; color: var(--color-text);">
            <%= @insights[:writing_velocity][:pace].titleize %>
          </p>
        </div>
      </div>
    </div>
  <% end %>
  
  <!-- Content Evolution -->
  <% if @insights[:content_evolution][:avg_length_change] %>
    <div class="card mb-4">
      <h2 class="mb-3">📈 Content Evolution</h2>
      
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 2rem;">
        <div>
          <div class="text-subtle mb-1">Early notes averaged</div>
          <h3 style="color: var(--color-text-subtle);">
            <%= @insights[:content_evolution][:avg_length_change][:before] %> words
          </h3>
        </div>
        
        <div style="display: flex; align-items: center; justify-content: center;">
          <span style="font-size: 2rem; color: var(--color-accent);">→</span>
        </div>
        
        <div>
          <div class="text-subtle mb-1">Recent notes average</div>
          <h3 style="color: var(--color-primary);">
            <%= @insights[:content_evolution][:avg_length_change][:after] %> words
          </h3>
        </div>
      </div>
      
      <% change = @insights[:content_evolution][:avg_length_change][:after] - @insights[:content_evolution][:avg_length_change][:before] %>
      <div style="margin-top: 1.5rem; padding: 1rem; background: var(--color-bg); border-radius: 6px;">
        <% if change > 0 %>
          <p class="text-subtle">📈 Your notes are getting more detailed over time (+<%= change %> words)</p>
        <% elsif change < 0 %>
          <p class="text-subtle">📉 Your notes are becoming more concise (<%= change %> words)</p>
        <% else %>
          <p class="text-subtle">➡️ Your note length has remained consistent</p>
        <% end %>
      </div>
    </div>
  <% end %>
  
  <!-- Topic Cloud -->
  <% if @insights[:topic_distribution][:common_themes].any? %>
    <div class="card mb-4">
      <h2 class="mb-3">💭 Common Themes</h2>
      
      <div style="display: flex; flex-wrap: wrap; gap: 0.75rem; margin-bottom: 1.5rem;">
        <% @insights[:topic_distribution][:common_themes].each do |theme| %>
          <span style="padding: 0.5rem 1rem; background: var(--color-bg); border: 1px solid var(--color-border); border-radius: 20px; font-size: 0.9rem;">
            <%= theme %>
          </span>
        <% end %>
      </div>
      
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem;">
        <div>
          <div class="text-subtle mb-1">Unique words used</div>
          <h3 style="color: var(--color-primary);"><%= number_to_human(@insights[:topic_distribution][:unique_words]) %></h3>
        </div>
        
        <div>
          <div class="text-subtle mb-1">Vocabulary richness</div>
          <h3 style="color: var(--color-accent);"><%= @insights[:topic_distribution][:vocabulary_richness] %>%</h3>
        </div>
      </div>
    </div>
  <% end %>
  
  <!-- Recent Notes -->
  <div class="card">
    <h2 class="mb-3">📝 Recent Notes</h2>
    
    <% if @recent_notes.any? %>
      <div style="display: grid; gap: 1rem;">
        <% @recent_notes.each do |note| %>
          <%= link_to note, style: "text-decoration: none; display: block; padding: 1.5rem; background: var(--color-bg); border-radius: 8px; transition: all 0.3s var(--ease-smooth);" do %>
            <h3 style="color: var(--color-text); margin-bottom: 0.5rem;"><%= note.title %></h3>
            <p style="color: var(--color-text-subtle); margin-bottom: 0.5rem;"><%= truncate(note.content, length: 150) %></p>
            <div class="flex gap-2 text-subtle" style="font-size: 0.85rem;">
              <span><%= note.content.to_s.split.length %> words</span>
              <span>•</span>
              <span><%= time_ago_in_words(note.updated_at) %> ago</span>
            </div>
          <% end %>
        <% end %>
      </div>
    <% else %>
      <p class="text-subtle text-center" style="padding: 2rem;">
        No notes yet. <%= link_to "Create your first note", new_note_path, style: "color: var(--color-primary);" %>!
      </p>
    <% end %>
  </div>
  
  <div class="mt-4">
    <%= link_to notes_path, class: "btn btn-ghost" do %>
      ← Back to Notes
    <% end %>
  </div>
</div>
HTML

echo "✓ Beautiful analytics dashboard created"

echo ""
echo "======================================"
echo "✅ Phase 5 Complete!"
echo "======================================"
echo ""
echo "Magic Features Added:"
echo "  🧠 Thinking Style Analysis"
echo "  ⏰ Peak Performance Times"
echo "  📊 Writing Velocity Tracking"
echo "  📈 Content Evolution Over Time"
echo "  💭 Topic Distribution & Themes"
echo "  📝 Vocabulary Richness"
echo "  🔥 Streak Tracking"
echo ""
echo "Visit /profile to see your cognitive insights!"
echo ""
echo "These insights get better as you write more notes!"
echo ""