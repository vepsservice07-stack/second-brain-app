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
