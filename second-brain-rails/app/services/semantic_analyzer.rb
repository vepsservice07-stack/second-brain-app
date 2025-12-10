# Analyzes semantic content locally (no external APIs)
# Uses TF-IDF and basic NLP for concept extraction
class SemanticAnalyzer
  class << self
    def analyze(text)
      return default_analysis if text.blank?
      
      {
        keywords: extract_keywords(text),
        concepts: extract_concepts(text),
        sentiment: analyze_sentiment(text),
        complexity: measure_complexity(text),
        summary: generate_summary(text)
      }
    end
    
    def extract_keywords(text, limit: 5)
      # Simple keyword extraction without stopwords gem
      # Remove common words manually
      common_words = %w[
        the be to of and a in that have i it for not on with he as you do at
        this but his by from they we say her she or an will my one all would
        there their what so up out if about who get which go me when make can
        like time no just him know take people into year your good some could
        them see other than then now look only come its over think also back
        after use two how our work first well way even new want because any
        these give day most us is was are been has had may does did am can
        could would should might must shall
      ]
      
      # Tokenize and filter
      words = text.downcase
                  .gsub(/[^\w\s]/, ' ')
                  .split
                  .reject { |w| w.length < 3 }
                  .reject { |w| common_words.include?(w) }
      
      # Count frequencies
      frequencies = words.tally
      
      # Return top keywords
      frequencies.sort_by { |_, count| -count }
                 .first(limit)
                 .map { |word, count| { word: word, frequency: count } }
    end
    
    def extract_concepts(text)
      # Extract multi-word concepts (capitalized phrases)
      concepts = []
      
      # Find capitalized phrases (potential concepts)
      text.scan(/[A-Z][a-z]+(?:\s+[A-Z][a-z]+)*/) do |match|
        concepts << match if match.split.length > 1
      end
      
      # Find quoted phrases (important concepts)
      text.scan(/"([^"]+)"/) do |match|
        concepts << match.first
      end
      
      concepts.uniq.first(10)
    end
    
    def analyze_sentiment(text)
      # Simple sentiment analysis based on word lists
      positive_words = %w[
        good great excellent wonderful amazing fantastic beautiful perfect
        happy joy love like best better improved success helpful useful
        clear simple easy effective powerful brilliant
      ]
      
      negative_words = %w[
        bad terrible horrible awful wrong poor worse worst failed problem
        difficult hard confusing unclear complex complicated issue error
        mistake broken fail
      ]
      
      words = text.downcase.split
      
      positive_count = words.count { |w| positive_words.include?(w) }
      negative_count = words.count { |w| negative_words.include?(w) }
      
      total = positive_count + negative_count
      return :neutral if total == 0
      
      score = (positive_count - negative_count).to_f / total
      
      case score
      when 0.5..1.0 then :very_positive
      when 0.2..0.5 then :positive
      when -0.2..0.2 then :neutral
      when -0.5..-0.2 then :negative
      else :very_negative
      end
    end
    
    def measure_complexity(text)
      words = text.split
      sentences = text.split(/[.!?]+/).reject(&:empty?)
      
      return :very_simple if sentences.empty?
      
      avg_words_per_sentence = words.length.to_f / sentences.length
      avg_word_length = words.sum { |w| w.length } / words.length.to_f
      
      # Complexity heuristic
      complexity_score = (avg_words_per_sentence * 0.5) + (avg_word_length * 2)
      
      case complexity_score
      when 0..10 then :very_simple
      when 10..15 then :simple
      when 15..20 then :moderate
      when 20..25 then :complex
      else :very_complex
      end
    end
    
    def generate_summary(text, max_sentences: 3)
      sentences = text.split(/[.!?]+/).map(&:strip).reject(&:empty?)
      
      return text if sentences.length <= max_sentences
      
      # Simple extractive summarization: pick first, middle, and last
      indices = [0]
      indices << sentences.length / 2 if sentences.length > 2
      indices << sentences.length - 1 if sentences.length > 1
      
      indices.uniq.map { |i| sentences[i] }.join('. ') + '.'
    end
    
    private
    
    def default_analysis
      {
        keywords: [],
        concepts: [],
        sentiment: :neutral,
        complexity: :very_simple,
        summary: ""
      }
    end
  end
end
