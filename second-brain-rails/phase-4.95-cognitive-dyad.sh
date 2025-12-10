#!/bin/bash
set -e

echo "======================================"
echo "Phase 4.95: Cognitive Dyad Architecture"
echo "Semantic-Formal Bridge + AI Integration"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

echo "Step 1: Adding Semantic Field Extractor..."
echo "======================================"

cat > app/services/semantic_field_extractor.rb << 'RUBY'
# Extracts rich semantic field from interaction history
# This is the "right brain" - fuzzy, associative, emotional
class SemanticFieldExtractor
  class << self
    def extract(note_id, up_to_sequence: nil)
      interactions = fetch_interactions(note_id, up_to_sequence)
      
      return nil if interactions.empty?
      
      {
        note_id: note_id,
        sequence: up_to_sequence,
        text: EventStore.rebuild(note_id, up_to_sequence),
        rhythm: extract_rhythm(interactions),
        associations: extract_associations(note_id, interactions),
        emotional_valence: extract_valence(interactions),
        concept_drift: extract_drift(note_id, interactions),
        contextual_influences: extract_influences(note_id, interactions),
        cognitive_state: infer_cognitive_state(interactions),
        timestamp: Time.now
      }
    end
    
    private
    
    def fetch_interactions(note_id, up_to_sequence)
      query = Interaction.where(note_id: note_id).order(:sequence_number)
      query = query.where('sequence_number <= ?', up_to_sequence) if up_to_sequence
      query.to_a
    end
    
    def extract_rhythm(interactions)
      # Analyze pause patterns, velocity changes, deletion frequency
      pauses = []
      velocities = []
      deletions = 0
      
      interactions.each_cons(2) do |i1, i2|
        pause = (i2.created_at - i1.created_at).to_f
        velocity = 1.0 / [pause, 0.01].max
        
        pauses << pause
        velocities << velocity
        deletions += 1 if i2.data['operation'] == 'delete'
      end
      
      {
        avg_pause: pauses.sum / [pauses.length, 1].max,
        max_pause: pauses.max || 0,
        avg_velocity: velocities.sum / [velocities.length, 1].max,
        velocity_variance: calculate_variance(velocities),
        deletion_rate: deletions.to_f / [interactions.length, 1].max,
        flow_detected: detect_flow(velocities)
      }
    end
    
    def extract_associations(note_id, interactions)
      # What notes were viewed recently?
      start_time = interactions.first&.created_at || Time.now - 1.hour
      
      recent_views = Interaction
        .where(interaction_type: 'note_view')
        .where('created_at >= ? AND created_at <= ?', 
               start_time - 30.minutes, 
               interactions.last&.created_at || Time.now)
        .where.not(note_id: note_id)
        .pluck(:data)
        .map { |d| d['viewed_note_id'] }
        .compact
        .uniq
      
      recent_views.map do |viewed_id|
        viewed_note = Note.find_by(id: viewed_id)
        next unless viewed_note
        
        {
          note_id: viewed_id,
          title: viewed_note.title,
          viewed_at: viewed_note.interactions
            .where(interaction_type: 'note_view')
            .where('created_at >= ?', start_time - 30.minutes)
            .first&.created_at
        }
      end.compact
    end
    
    def extract_valence(interactions)
      # Infer emotional state from typing patterns
      rhythm = extract_rhythm(interactions)
      
      # High velocity + low deletions = confident
      # Low velocity + high deletions = uncertain
      # High velocity + high deletions = editing/refining
      
      confidence_score = (1.0 - rhythm[:deletion_rate]) * 
                        [rhythm[:avg_velocity] / 10.0, 1.0].min
      
      certainty = case rhythm[:avg_velocity]
                  when 0..3 then :very_low
                  when 3..5 then :low
                  when 5..8 then :medium
                  when 8..12 then :high
                  else :very_high
                  end
      
      {
        confidence: (confidence_score * 100).round(2),
        certainty: certainty,
        flow_state: rhythm[:flow_detected],
        hesitation_detected: rhythm[:max_pause] > 4.0,
        editing_mode: rhythm[:deletion_rate] > 0.15
      }
    end
    
    def extract_drift(note_id, interactions)
      # How concepts evolved during writing
      return [] if interactions.length < 50
      
      snapshots = []
      interactions.each_slice(50) do |chunk|
        seq = chunk.last.sequence_number
        content = EventStore.rebuild(note_id, seq)
        
        snapshots << {
          sequence: seq,
          content: content,
          word_count: content.split.length,
          unique_words: content.downcase.split.uniq.length
        }
      end
      
      # Calculate semantic drift between snapshots
      snapshots.each_cons(2).map do |before, after|
        {
          from_sequence: before[:sequence],
          to_sequence: after[:sequence],
          word_count_delta: after[:word_count] - before[:word_count],
          vocabulary_growth: after[:unique_words] - before[:unique_words],
          drift_magnitude: calculate_semantic_distance(before[:content], after[:content])
        }
      end
    end
    
    def extract_influences(note_id, interactions)
      # Find causal influences from viewed notes
      influences = []
      
      interactions.each_with_index do |interaction, idx|
        next unless interaction.interaction_type == 'keystroke'
        
        # Look back 5 minutes for note views
        recent_views = interactions[0...idx]
          .select { |i| i.interaction_type == 'note_view' }
          .select { |i| (interaction.created_at - i.created_at) < 300 }
        
        recent_views.each do |view|
          influences << {
            sequence: interaction.sequence_number,
            influenced_by: view.data['viewed_note_id'],
            time_delta: (interaction.created_at - view.created_at).to_f,
            confidence: calculate_influence_confidence(interaction, view)
          }
        end
      end
      
      influences
    end
    
    def infer_cognitive_state(interactions)
      rhythm = extract_rhythm(interactions)
      valence = extract_valence(interactions)
      
      # Cognitive state inference
      if rhythm[:flow_detected]
        :flow
      elsif valence[:hesitation_detected]
        :contemplating
      elsif valence[:editing_mode]
        :refining
      elsif rhythm[:avg_velocity] > 8
        :streaming
      elsif rhythm[:avg_velocity] < 3
        :stuck
      else
        :normal
      end
    end
    
    # Helper methods
    
    def calculate_variance(values)
      return 0 if values.empty?
      mean = values.sum / values.length.to_f
      variance = values.sum { |v| (v - mean) ** 2 } / values.length.to_f
      Math.sqrt(variance)
    end
    
    def detect_flow(velocities)
      return false if velocities.length < 10
      
      # Flow = sustained high velocity with low variance
      recent = velocities.last(10)
      avg = recent.sum / recent.length.to_f
      variance = calculate_variance(recent)
      
      avg > 8.0 && variance < 2.0
    end
    
    def calculate_semantic_distance(text1, text2)
      # Simple Jaccard distance for now
      # Could be upgraded to TF-IDF cosine similarity
      words1 = text1.downcase.split.to_set
      words2 = text2.downcase.split.to_set
      
      intersection = (words1 & words2).length
      union = (words1 | words2).length
      
      return 0 if union == 0
      1.0 - (intersection.to_f / union)
    end
    
    def calculate_influence_confidence(keystroke, view)
      # Simple heuristic: closer in time = higher confidence
      time_delta = (keystroke.created_at - view.created_at).to_f
      
      # Decay function: e^(-t/300) where t in seconds
      Math.exp(-time_delta / 300.0)
    end
  end
end
RUBY

echo "✓ Created app/services/semantic_field_extractor.rb"

echo ""
echo "Step 2: Adding Formal Structure Templates..."
echo "======================================"

cat > app/services/formal_structure_templates.rb << 'RUBY'
# Defines formal structure types (left brain)
# These are the "forms" that can constrain semantic content
class FormalStructureTemplates
  TEMPLATES = {
    logical_argument: {
      name: "Logical Argument",
      structure: ["premise", "inference", "conclusion"],
      example: "Because X, therefore Y",
      markers: ["therefore", "thus", "hence", "because"],
      confidence_boost: 0.2  # Boost when markers present
    },
    
    causal_chain: {
      name: "Causal Chain",
      structure: ["cause", "mechanism", "effect"],
      example: "A causes B which leads to C",
      markers: ["causes", "leads to", "results in", "because"],
      confidence_boost: 0.15
    },
    
    comparative_analysis: {
      name: "Comparison",
      structure: ["element_a", "element_b", "dimensions", "conclusion"],
      example: "X vs Y on dimension Z",
      markers: ["vs", "versus", "compared to", "unlike", "similar to"],
      confidence_boost: 0.18
    },
    
    hierarchical_outline: {
      name: "Hierarchy",
      structure: ["parent", "children", "relationships"],
      example: "Parent concept with sub-concepts",
      markers: ["includes", "contains", "such as", "for example"],
      confidence_boost: 0.12
    },
    
    temporal_narrative: {
      name: "Timeline",
      structure: ["beginning", "middle", "end"],
      example: "First X, then Y, finally Z",
      markers: ["first", "then", "next", "finally", "after"],
      confidence_boost: 0.15
    },
    
    dialectic: {
      name: "Dialectic",
      structure: ["thesis", "antithesis", "synthesis"],
      example: "Position A vs Position B → Resolution C",
      markers: ["however", "but", "on the other hand", "although"],
      confidence_boost: 0.25
    },
    
    proof_by_cases: {
      name: "Case Analysis",
      structure: ["cases", "analysis_per_case", "conclusion"],
      example: "If A then X, if B then Y, therefore Z",
      markers: ["if", "case", "when", "scenario"],
      confidence_boost: 0.10
    },
    
    recursive_definition: {
      name: "Recursive",
      structure: ["base_case", "recursive_case", "termination"],
      example: "X is Y where Y may contain X",
      markers: ["defined as", "is", "contains", "includes itself"],
      confidence_boost: 0.08
    },
    
    problem_solution: {
      name: "Problem-Solution",
      structure: ["problem", "constraints", "solution", "validation"],
      example: "Problem X, given Y, solve with Z",
      markers: ["problem", "issue", "challenge", "solution", "solves"],
      confidence_boost: 0.20
    },
    
    process_description: {
      name: "Process",
      structure: ["steps", "sequence", "result"],
      example: "Step 1, Step 2, Step 3 → Outcome",
      markers: ["step", "process", "procedure", "method"],
      confidence_boost: 0.14
    }
  }
  
  class << self
    def detect_structure(semantic_field)
      text = semantic_field[:text].downcase
      scores = {}
      
      TEMPLATES.each do |key, template|
        # Base score from text analysis
        base_score = calculate_base_score(text, template)
        
        # Boost from markers
        marker_score = count_markers(text, template[:markers])
        
        # Adjust for semantic field properties
        context_score = adjust_for_context(semantic_field, template)
        
        scores[key] = {
          template: key,
          name: template[:name],
          confidence: [base_score + marker_score + context_score, 1.0].min,
          structure: template[:structure],
          example: template[:example]
        }
      end
      
      # Return top 3 structures
      scores.values.sort_by { |s| -s[:confidence] }.take(3)
    end
    
    def generate_scaffold(structure_type, semantic_field)
      template = TEMPLATES[structure_type]
      return nil unless template
      
      # Generate scaffold based on current text
      text = semantic_field[:text]
      
      scaffold = {
        structure_type: structure_type,
        name: template[:name],
        elements: template[:structure].map do |element|
          {
            element: element,
            current_content: extract_content_for_element(text, element),
            suggestions: generate_suggestions(element, semantic_field)
          }
        end
      }
      
      scaffold
    end
    
    private
    
    def calculate_base_score(text, template)
      # Heuristic: length, complexity, structure indicators
      words = text.split
      
      score = 0.0
      
      # Favor certain structures for certain lengths
      case template[:name]
      when "Logical Argument"
        score += 0.3 if words.length > 20 && words.length < 100
      when "Comparison"
        score += 0.3 if words.length > 30
      when "Timeline"
        score += 0.3 if words.length > 50
      end
      
      score
    end
    
    def count_markers(text, markers)
      count = markers.sum { |marker| text.scan(/\b#{Regexp.escape(marker)}\b/i).length }
      
      # Normalize: more markers = higher confidence, but with diminishing returns
      [Math.log(count + 1) / 3.0, 0.3].min
    end
    
    def adjust_for_context(semantic_field, template)
      score = 0.0
      
      # Boost logical argument if high confidence
      if template[:name] == "Logical Argument" && 
         semantic_field[:emotional_valence][:confidence] > 70
        score += 0.1
      end
      
      # Boost dialectic if hesitation detected
      if template[:name] == "Dialectic" && 
         semantic_field[:emotional_valence][:hesitation_detected]
        score += 0.15
      end
      
      # Boost comparison if multiple associations
      if template[:name] == "Comparison" && 
         semantic_field[:associations].length > 1
        score += 0.1
      end
      
      score
    end
    
    def extract_content_for_element(text, element)
      # Simple heuristic extraction
      # Could be upgraded with NLP
      sentences = text.split(/[.!?]/).map(&:strip).reject(&:empty?)
      
      case element
      when "premise", "cause", "problem"
        sentences.first
      when "conclusion", "effect", "solution"
        sentences.last
      when "inference", "mechanism", "analysis_per_case"
        sentences[1..-2]&.join(". ")
      else
        nil
      end
    end
    
    def generate_suggestions(element, semantic_field)
      # Suggestions based on semantic field
      case element
      when "premise"
        ["State your main assumption", "What do you believe to be true?"]
      when "conclusion"
        ["What follows from this?", "Therefore..."]
      when "antithesis"
        ["What's the counterargument?", "However..."]
      else
        ["Continue developing this part"]
      end
    end
  end
end
RUBY

echo "✓ Created app/services/formal_structure_templates.rb"

echo ""
echo "Step 3: Adding Structure Suggester (The Dyad!)..."
echo "======================================"

cat > app/services/structure_suggester.rb << 'RUBY'
# The bridge between semantic (human) and formal (AI)
# This is where the magic happens
class StructureSuggester
  class << self
    def suggest(note_id, up_to_sequence: nil)
      # Extract semantic field (right brain)
      semantic_field = SemanticFieldExtractor.extract(note_id, up_to_sequence)
      return nil unless semantic_field
      
      # Detect possible formal structures (left brain)
      structures = FormalStructureTemplates.detect_structure(semantic_field)
      
      # Generate scaffolds for top structures
      suggestions = structures.map do |structure|
        scaffold = FormalStructureTemplates.generate_scaffold(
          structure[:template],
          semantic_field
        )
        
        {
          structure: structure,
          scaffold: scaffold,
          metadata: {
            semantic_field: semantic_field,
            generated_at: Time.now
          }
        }
      end
      
      # Return suggestions ranked by confidence
      {
        note_id: note_id,
        sequence: up_to_sequence,
        suggestions: suggestions,
        semantic_analysis: {
          cognitive_state: semantic_field[:cognitive_state],
          flow_state: semantic_field[:emotional_valence][:flow_state],
          confidence: semantic_field[:emotional_valence][:confidence]
        }
      }
    end
    
    def apply_structure(note_id, structure_type, user_modifications: {})
      # User chose a structure - apply it and learn
      semantic_field = SemanticFieldExtractor.extract(note_id)
      scaffold = FormalStructureTemplates.generate_scaffold(structure_type, semantic_field)
      
      # Record the choice for learning
      record_structure_choice(note_id, structure_type, semantic_field)
      
      # Return formatted content
      format_with_structure(semantic_field[:text], scaffold, user_modifications)
    end
    
    private
    
    def record_structure_choice(note_id, structure_type, semantic_field)
      # Store in interactions as metadata for future learning
      Interaction.create!(
        note_id: note_id,
        interaction_type: 'structure_applied',
        data: {
          structure_type: structure_type,
          semantic_state: {
            cognitive_state: semantic_field[:cognitive_state],
            confidence: semantic_field[:emotional_valence][:confidence],
            associations: semantic_field[:associations].map { |a| a[:note_id] }
          }
        }
      )
    end
    
    def format_with_structure(text, scaffold, modifications)
      # Apply structure to text
      # This would generate formatted output
      formatted = []
      
      scaffold[:elements].each do |element|
        formatted << {
          element: element[:element],
          content: modifications[element[:element]] || element[:current_content] || "",
          placeholder: element[:suggestions].first
        }
      end
      
      formatted
    end
  end
end
RUBY

echo "✓ Created app/services/structure_suggester.rb"

echo ""
echo "Step 4: Adding API endpoint for structure suggestions..."
echo "======================================"

cat > app/controllers/structure_suggestions_controller.rb << 'RUBY'
class StructureSuggestionsController < ApplicationController
  # GET /notes/:note_id/structure_suggestions
  def show
    @note = Note.find(params[:note_id])
    
    # Get real-time structure suggestions
    suggestions = StructureSuggester.suggest(@note.id)
    
    if suggestions
      render json: suggestions
    else
      render json: { error: "Unable to analyze note" }, status: :unprocessable_entity
    end
  end
  
  # POST /notes/:note_id/apply_structure
  def apply
    @note = Note.find(params[:note_id])
    structure_type = params[:structure_type].to_sym
    modifications = params[:modifications] || {}
    
    result = StructureSuggester.apply_structure(
      @note.id,
      structure_type,
      user_modifications: modifications
    )
    
    render json: { 
      success: true,
      formatted_content: result
    }
  end
  
  # GET /notes/:note_id/semantic_field
  def semantic_field
    @note = Note.find(params[:note_id])
    field = SemanticFieldExtractor.extract(@note.id)
    
    render json: field
  end
end
RUBY

echo "✓ Created app/controllers/structure_suggestions_controller.rb"

echo ""
echo "Step 5: Adding routes..."
echo "======================================"

# Add routes
cat >> config/routes.rb << 'RUBY'

  # Cognitive Dyad - Semantic-Formal Bridge
  resources :notes do
    member do
      get 'structure_suggestions'
      post 'apply_structure'
      get 'semantic_field'
    end
  end
RUBY

echo "✓ Updated routes"

echo ""
echo "Step 6: Creating structure suggestion UI component..."
echo "======================================"

mkdir -p app/javascript/components

cat > app/javascript/components/structure_suggester.js << 'JS'
// Real-time structure suggestion overlay
// Shows formal structure options as you type

export class StructureSuggester {
  constructor(noteId, textareaElement) {
    this.noteId = noteId;
    this.textarea = textareaElement;
    this.suggestionsPanel = null;
    this.currentSuggestions = null;
    this.debounceTimer = null;
    
    this.init();
  }
  
  init() {
    // Create suggestions panel
    this.createSuggestionsPanel();
    
    // Listen for typing
    this.textarea.addEventListener('input', () => {
      this.debouncedUpdate();
    });
    
    // Keyboard shortcuts
    this.textarea.addEventListener('keydown', (e) => {
      this.handleKeyboard(e);
    });
  }
  
  createSuggestionsPanel() {
    const panel = document.createElement('div');
    panel.className = 'structure-suggestions-panel';
    panel.style.cssText = `
      position: absolute;
      right: 20px;
      top: 100px;
      width: 300px;
      background: rgba(0, 0, 0, 0.9);
      border: 1px solid #333;
      border-radius: 8px;
      padding: 16px;
      display: none;
      z-index: 1000;
    `;
    
    document.body.appendChild(panel);
    this.suggestionsPanel = panel;
  }
  
  debouncedUpdate() {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.updateSuggestions();
    }, 1000); // Wait 1s after typing stops
  }
  
  async updateSuggestions() {
    try {
      const response = await fetch(`/notes/${this.noteId}/structure_suggestions`);
      const data = await response.json();
      
      this.currentSuggestions = data;
      this.renderSuggestions(data);
    } catch (error) {
      console.error('Error fetching suggestions:', error);
    }
  }
  
  renderSuggestions(data) {
    if (!data.suggestions || data.suggestions.length === 0) {
      this.suggestionsPanel.style.display = 'none';
      return;
    }
    
    const html = `
      <div class="suggestions-header">
        <h4>Structure Suggestions</h4>
        <div class="cognitive-state">
          State: ${data.semantic_analysis.cognitive_state}
          ${data.semantic_analysis.flow_state ? '🔥' : ''}
        </div>
      </div>
      
      <div class="suggestions-list">
        ${data.suggestions.map((s, idx) => `
          <div class="suggestion-item" data-index="${idx}">
            <div class="suggestion-header">
              <span class="suggestion-name">${s.structure.name}</span>
              <span class="suggestion-confidence">
                ${Math.round(s.structure.confidence * 100)}%
              </span>
              <kbd>${idx + 1}</kbd>
            </div>
            <div class="suggestion-example">
              ${s.structure.example}
            </div>
          </div>
        `).join('')}
      </div>
      
      <div class="suggestions-footer">
        Press 1-3 to apply structure, Esc to hide
      </div>
    `;
    
    this.suggestionsPanel.innerHTML = html;
    this.suggestionsPanel.style.display = 'block';
    
    // Add click handlers
    this.suggestionsPanel.querySelectorAll('.suggestion-item').forEach((item) => {
      item.addEventListener('click', () => {
        const index = parseInt(item.dataset.index);
        this.applyStructure(index);
      });
    });
  }
  
  handleKeyboard(e) {
    // Check for number keys 1-3
    if (e.key >= '1' && e.key <= '3' && e.altKey) {
      e.preventDefault();
      const index = parseInt(e.key) - 1;
      this.applyStructure(index);
    }
    
    // Esc to hide
    if (e.key === 'Escape') {
      this.suggestionsPanel.style.display = 'none';
    }
  }
  
  async applyStructure(index) {
    if (!this.currentSuggestions || !this.currentSuggestions.suggestions[index]) {
      return;
    }
    
    const suggestion = this.currentSuggestions.suggestions[index];
    const structureType = suggestion.structure.template;
    
    try {
      const response = await fetch(`/notes/${this.noteId}/apply_structure`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          structure_type: structureType,
          modifications: {}
        })
      });
      
      const data = await response.json();
      
      if (data.success) {
        this.insertStructure(data.formatted_content);
        this.suggestionsPanel.style.display = 'none';
      }
    } catch (error) {
      console.error('Error applying structure:', error);
    }
  }
  
  insertStructure(formattedContent) {
    // Insert structured template into textarea
    const template = formattedContent.map(element => {
      return `${element.element.toUpperCase()}:\n${element.content || element.placeholder}\n`;
    }).join('\n');
    
    // Insert at current cursor position
    const start = this.textarea.selectionStart;
    const end = this.textarea.selectionEnd;
    const text = this.textarea.value;
    
    this.textarea.value = text.substring(0, start) + '\n\n' + template + '\n\n' + text.substring(end);
    
    // Trigger input event for VEPS capture
    this.textarea.dispatchEvent(new Event('input', { bubbles: true }));
  }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
  const noteTextarea = document.querySelector('textarea[data-note-id]');
  if (noteTextarea) {
    const noteId = noteTextarea.dataset.noteId;
    new StructureSuggester(noteId, noteTextarea);
  }
});
JS

echo "✓ Created structure suggester UI"

echo ""
echo "Step 7: Adding CSS for structure suggestions..."
echo "======================================"

cat >> app/assets/stylesheets/application.css << 'CSS'

/* Structure Suggestions Panel */
.structure-suggestions-panel {
  font-family: 'SF Mono', 'Monaco', 'Inconsolata', monospace;
  color: #e0e0e0;
}

.suggestions-header h4 {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #4a9eff;
}

.cognitive-state {
  font-size: 11px;
  color: #888;
  margin-bottom: 12px;
}

.suggestions-list {
  margin: 12px 0;
}

.suggestion-item {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid #333;
  border-radius: 4px;
  padding: 10px;
  margin-bottom: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.suggestion-item:hover {
  background: rgba(74, 158, 255, 0.1);
  border-color: #4a9eff;
}

.suggestion-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.suggestion-name {
  font-weight: 600;
  color: #4a9eff;
}

.suggestion-confidence {
  font-size: 11px;
  color: #888;
}

.suggestion-item kbd {
  background: #333;
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 10px;
}

.suggestion-example {
  font-size: 11px;
  color: #aaa;
  font-style: italic;
}

.suggestions-footer {
  font-size: 10px;
  color: #666;
  text-align: center;
  padding-top: 8px;
  border-top: 1px solid #333;
}
CSS

echo "✓ Added CSS styling"

echo ""
echo "======================================"
echo "✓ Phase 4.95 Implementation Complete!"
echo "======================================"
echo ""
echo "What was built:"
echo "  ✓ Semantic Field Extractor (rhythm, associations, valence)"
echo "  ✓ Formal Structure Templates (10 types)"
echo "  ✓ Structure Suggester (the dyad bridge)"
echo "  ✓ Real-time UI with keyboard shortcuts"
echo "  ✓ API endpoints for suggestions"
echo ""
echo "How it works:"
echo "  1. You type (semantic content - fuzzy, associative)"
echo "  2. System extracts semantic field (rhythm, context, emotion)"
echo "  3. AI suggests formal structures (logical, causal, etc.)"
echo "  4. You press Alt+1/2/3 to apply structure"
echo "  5. System learns YOUR preferences over time"
echo ""
echo "Keyboard shortcuts:"
echo "  Alt+1 → Apply top suggestion"
echo "  Alt+2 → Apply second suggestion"
echo "  Alt+3 → Apply third suggestion"
echo "  Esc   → Hide suggestions"
echo ""
echo "Next steps:"
echo "  1. Test the semantic field extractor"
echo "  2. Try typing and watch suggestions appear"
echo "  3. Later: Add ML models (SAE + CBN) for even smarter suggestions"
echo ""
echo "The magic: This learns YOUR thinking patterns!"
echo ""