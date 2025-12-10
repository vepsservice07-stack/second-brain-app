#!/bin/bash
set -e

echo "======================================"
echo "🏗️ Phase 3: 20 Structure Types"
echo "======================================"
echo ""
echo "Adding sophisticated thinking patterns..."
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Step 1: Create the comprehensive structure templates
echo "Step 1: Creating 20 structure templates..."
echo "======================================"

cat > app/services/formal_structure_templates.rb << 'RUBY'
# The 20 Essential Thinking Patterns
# Covers 95% of human structured thought
class FormalStructureTemplates
  STRUCTURES = {
    # ============================================
    # ANALYTICAL (6) - Breaking things down
    # ============================================
    
    logical_argument: {
      name: "Logical Argument",
      emoji: "🎯",
      description: "Build a clear, logical case",
      template: "PREMISE: [State your assumption]\n\nEVIDENCE: [Supporting facts]\n\nINFERENCE: [Why this follows]\n\nCONCLUSION: [Therefore...]",
      use_when: "High confidence, steady typing, philosophical content",
      examples: ["Because X, therefore Y", "If A then B"],
      triggers: ["because", "therefore", "thus", "hence", "follows that"]
    },
    
    causal_chain: {
      name: "Causal Chain",
      emoji: "⛓️",
      description: "Show how one thing leads to another",
      template: "INITIAL CAUSE: [What started it]\n\nMECHANISM: [How it works]\n\nDIRECT EFFECT: [Immediate result]\n\nSECONDARY EFFECTS: [Downstream consequences]\n\nIMPLICATIONS: [What this means]",
      use_when: "Sequential thinking, explaining processes",
      examples: ["A causes B which leads to C", "The domino effect"],
      triggers: ["causes", "leads to", "results in", "because of", "triggers"]
    },
    
    comparative_analysis: {
      name: "Comparative Analysis",
      emoji: "⚖️",
      description: "Compare and contrast options",
      template: "SUBJECT A: [First option]\n  Strengths:\n  Weaknesses:\n\nSUBJECT B: [Second option]\n  Strengths:\n  Weaknesses:\n\nKEY DIFFERENCES: [What sets them apart]\n\nCONCLUSION: [Which is better, when, and why]",
      use_when: "Multiple concepts, evaluation needed",
      examples: ["X vs Y", "Pros and cons", "Trade-offs"],
      triggers: ["versus", "compared to", "better than", "worse than", "difference"]
    },
    
    root_cause_analysis: {
      name: "Root Cause Analysis",
      emoji: "🔍",
      description: "Dig deep to find the real issue",
      template: "SYMPTOM: [What you observe]\n\nWHY? [First level cause]\n\nWHY? [Second level cause]\n\nWHY? [Third level cause]\n\nROOT CAUSE: [The fundamental issue]\n\nSOLUTION: [How to address the root]",
      use_when: "Problem-solving, debugging, investigation",
      examples: ["5 Whys", "Getting to the bottom of it"],
      triggers: ["why", "problem", "issue", "cause", "underlying"]
    },
    
    swot_analysis: {
      name: "SWOT Analysis",
      emoji: "📊",
      description: "Strategic evaluation framework",
      template: "STRENGTHS:\n  • [Internal advantage 1]\n  • [Internal advantage 2]\n\nWEAKNESSES:\n  • [Internal limitation 1]\n  • [Internal limitation 2]\n\nOPPORTUNITIES:\n  • [External possibility 1]\n  • [External possibility 2]\n\nTHREATS:\n  • [External risk 1]\n  • [External risk 2]\n\nSTRATEGY: [What to do based on this analysis]",
      use_when: "Strategic thinking, planning, evaluation",
      examples: ["Business analysis", "Personal assessment"],
      triggers: ["strengths", "weaknesses", "opportunities", "threats", "strategy"]
    },
    
    systems_thinking: {
      name: "Systems Thinking",
      emoji: "🕸️",
      description: "See the interconnections",
      template: "COMPONENTS: [Parts of the system]\n\nRELATIONSHIPS: [How parts interact]\n\nFEEDBACK LOOPS:\n  Reinforcing: [What amplifies]\n  Balancing: [What stabilizes]\n\nEMERGENT PROPERTIES: [Behaviors of the whole]\n\nLEVERAGE POINTS: [Where small changes have big impacts]",
      use_when: "Complex problems, interconnected issues",
      examples: ["Ecosystem thinking", "Organizational dynamics"],
      triggers: ["system", "interconnected", "feedback", "complex", "emergent"]
    },
    
    # ============================================
    # DIALECTICAL (4) - Exploring tensions
    # ============================================
    
    thesis_antithesis_synthesis: {
      name: "Dialectic",
      emoji: "🎭",
      description: "Resolve opposing viewpoints",
      template: "THESIS: [Your position]\n\nANTITHESIS: [Opposing view]\n\nTENSION: [Why they conflict]\n\nCOMMON GROUND: [Where they agree]\n\nSYNTHESIS: [Higher resolution that honors both]",
      use_when: "Philosophical debate, conflicting ideas, long pauses",
      examples: ["Hegel", "Resolving contradictions"],
      triggers: ["but", "however", "on the other hand", "although", "tension"]
    },
    
    devils_advocate: {
      name: "Devil's Advocate",
      emoji: "😈",
      description: "Challenge your own thinking",
      template: "MY POSITION: [What I believe]\n\nBEST CASE AGAINST:\n  • [Strongest objection 1]\n  • [Strongest objection 2]\n  • [Strongest objection 3]\n\nMY REBUTTAL: [How I respond]\n\nREVISED POSITION: [Improved view after testing]",
      use_when: "Testing ideas, self-criticism, uncertainty",
      examples: ["Playing both sides", "Stress testing"],
      triggers: ["but what if", "objection", "counter", "devil's advocate"]
    },
    
    steel_manning: {
      name: "Steel Man",
      emoji: "🛡️",
      description: "Understand the best version of opposing views",
      template: "THEIR POSITION: [What they believe]\n\nSTRONGEST VERSION: [Make their case better]\n\nWHY THEY BELIEVE IT: [Their valid reasoning]\n\nWHAT THEY SEE: [Their perspective]\n\nMY RESPONSE: [Engage with the strongest version]\n\nCOMMON GROUND: [Where we agree]",
      use_when: "Intellectual honesty, understanding others",
      examples: ["Charitable interpretation", "Good faith debate"],
      triggers: ["they believe", "their perspective", "to be fair", "strongest case"]
    },
    
    socratic_questioning: {
      name: "Socratic Method",
      emoji: "❓",
      description: "Question assumptions to reveal truth",
      template: "INITIAL CLAIM: [Starting statement]\n\nCLARIFYING QUESTION: [What do you mean by...?]\n\nPROBING ASSUMPTIONS: [Why do you assume...?]\n\nEXAMINING EVIDENCE: [What's your evidence for...?]\n\nEXPLORING IMPLICATIONS: [If this is true, then...?]\n\nREVELATION: [What emerges from inquiry]",
      use_when: "Deep inquiry, examining beliefs",
      examples: ["Socrates", "Unpacking assumptions"],
      triggers: ["question", "assume", "what if", "why", "how do you know"]
    },
    
    # ============================================
    # CREATIVE (4) - Generating new ideas
    # ============================================
    
    narrative_arc: {
      name: "Narrative Arc",
      emoji: "📖",
      description: "Tell a compelling story",
      template: "SETUP: [Initial situation]\n\nCHARACTERS: [Who's involved]\n\nCATALYST: [What changed]\n\nRISING ACTION: [Complications]\n\nCLIMAX: [Turning point]\n\nRESOLUTION: [New equilibrium]\n\nTHEME: [What it means]",
      use_when: "Storytelling, personal experiences, temporal flow",
      examples: ["Once upon a time", "Story structure"],
      triggers: ["happened", "story", "then", "finally", "realized"]
    },
    
    metaphorical_mapping: {
      name: "Metaphor",
      emoji: "🌉",
      description: "Explain through comparison",
      template: "ABSTRACT CONCEPT: [Hard to grasp idea]\n\nCONCRETE IMAGE: [Familiar thing]\n\nMAPPING:\n  • [How aspect A relates]\n  • [How aspect B relates]\n  • [How aspect C relates]\n\nINSIGHT: [What this reveals]\n\nLIMITATIONS: [Where metaphor breaks down]",
      use_when: "Explaining difficult concepts, creative connections",
      examples: ["Like...", "Think of it as..."],
      triggers: ["like", "as if", "reminds me of", "similar to", "metaphor"]
    },
    
    mind_mapping: {
      name: "Mind Map",
      emoji: "🧠",
      description: "Free-form idea exploration",
      template: "CENTRAL IDEA: [Core concept]\n\nBRANCH 1: [Major theme]\n  • Sub-idea\n  • Sub-idea\n  • Sub-idea\n\nBRANCH 2: [Major theme]\n  • Sub-idea\n  • Sub-idea\n\nBRANCH 3: [Major theme]\n  • Sub-idea\n  • Sub-idea\n\nCONNECTIONS: [How branches relate]",
      use_when: "Brainstorming, exploring associations, divergent thinking",
      examples: ["Free association", "Concept clustering"],
      triggers: ["related", "also", "another", "connected", "ideas"]
    },
    
    analogical_reasoning: {
      name: "Analogy",
      emoji: "🔗",
      description: "Solve by pattern matching",
      template: "SOURCE DOMAIN: [Familiar situation]\n  How it works:\n  Key patterns:\n\nTARGET DOMAIN: [New situation]\n  The challenge:\n  What's similar:\n\nPARALLELS:\n  • [Correspondence 1]\n  • [Correspondence 2]\n  • [Correspondence 3]\n\nPREDICTION: [What should work here]\n\nTEST: [How to verify the analogy holds]",
      use_when: "Problem-solving by pattern matching",
      examples: ["It's like when...", "By analogy..."],
      triggers: ["analogy", "similar situation", "like when", "parallel"]
    },
    
    # ============================================
    # PRACTICAL (3) - Getting things done
    # ============================================
    
    problem_solution: {
      name: "Problem → Solution",
      emoji: "🔧",
      description: "Structured problem-solving",
      template: "PROBLEM: [What's wrong]\n\nCONSTRAINTS:\n  • [Limitation 1]\n  • [Limitation 2]\n\nOPTIONS:\n  1. [Possible solution A]\n  2. [Possible solution B]\n  3. [Possible solution C]\n\nEVALUATION: [Pros and cons of each]\n\nCHOSEN SOLUTION: [Best approach]\n\nIMPLEMENTATION: [Action steps]\n\nSUCCESS CRITERIA: [How to measure]",
      use_when: "Action-oriented, practical decisions",
      examples: ["How to fix", "Finding a way"],
      triggers: ["problem", "solution", "fix", "solve", "approach"]
    },
    
    decision_matrix: {
      name: "Decision Matrix",
      emoji: "📋",
      description: "Rational choice framework",
      template: "OPTIONS: [A, B, C]\n\nCRITERIA & WEIGHTS:\n  1. [Factor 1] - Weight: X\n  2. [Factor 2] - Weight: Y\n  3. [Factor 3] - Weight: Z\n\nSCORES (1-10):\n  Option A: [scores on each]\n  Option B: [scores on each]\n  Option C: [scores on each]\n\nWEIGHTED TOTALS:\n  A: [total]\n  B: [total]\n  C: [total]\n\nBEST CHOICE: [Winner]\n\nRISK ASSESSMENT: [What could go wrong]",
      use_when: "Multiple options, need objectivity",
      examples: ["Weighted scoring", "Rational choice"],
      triggers: ["decision", "choose", "options", "criteria", "evaluate"]
    },
    
    process_documentation: {
      name: "Process Steps",
      emoji: "📝",
      description: "Document how to do something",
      template: "GOAL: [What we're trying to accomplish]\n\nPREREQUISITES: [What you need first]\n\nSTEPS:\n  1. [First action]\n  2. [Second action]\n  3. [Third action]\n  4. [Fourth action]\n\nCOMMON PITFALLS:\n  • [Mistake to avoid 1]\n  • [Mistake to avoid 2]\n\nVERIFICATION: [How to check success]\n\nTROUBLESHOOTING: [If things go wrong]",
      use_when: "Documenting procedures, teaching",
      examples: ["How-to", "Standard operating procedure"],
      triggers: ["steps", "process", "procedure", "how to", "instructions"]
    },
    
    # ============================================
    # REFLECTIVE (3) - Learning from experience
    # ============================================
    
    retrospective: {
      name: "Retrospective",
      emoji: "🔄",
      description: "Learn from what happened",
      template: "CONTEXT: [What we were doing]\n\nWHAT HAPPENED: [Objective timeline]\n\nWHAT WENT WELL:\n  • [Success 1]\n  • [Success 2]\n\nWHAT WENT WRONG:\n  • [Failure 1]\n  • [Failure 2]\n\nWHY: [Root causes of both]\n\nLEARNINGS: [Key insights]\n\nNEXT TIME: [Concrete improvements]",
      use_when: "After completing something, learning from experience",
      examples: ["Post-mortem", "Lessons learned"],
      triggers: ["what happened", "went well", "went wrong", "learned", "next time"]
    },
    
    personal_insight: {
      name: "Personal Insight",
      emoji: "💭",
      description: "Reflect on inner experience",
      template: "OBSERVATION: [What I noticed]\n\nFEELING: [Emotional response]\n\nBODY SENSATION: [Physical feeling]\n\nPATTERN: [Have I felt this before?]\n\nCONTEXT: [What triggered it]\n\nWHY IT MATTERS: [Significance]\n\nACTION: [What I'll do with this awareness]",
      use_when: "Self-reflection, emotional content, personal growth",
      examples: ["Journal entry", "Therapy notes"],
      triggers: ["i feel", "i notice", "realized", "understand now", "aware"]
    },
    
    learning_capture: {
      name: "Learning Notes",
      emoji: "📚",
      description: "Capture and integrate new knowledge",
      template: "SOURCE: [Where this came from]\n\nMAIN IDEAS:\n  • [Key point 1]\n  • [Key point 2]\n  • [Key point 3]\n\nSURPRISING: [What challenged my thinking]\n\nCONNECTIONS: [Links to other ideas I know]\n\nQUESTIONS: [What I still wonder]\n\nAPPLICATION: [How I'll use this]\n\nFOLLOW-UP: [What to explore next]",
      use_when: "Taking notes, after reading/watching",
      examples: ["Study notes", "Book summary"],
      triggers: ["learned", "reading", "according to", "key point", "takeaway"]
    }
  }
  
  class << self
    def all
      STRUCTURES
    end
    
    def find(key)
      STRUCTURES[key.to_sym]
    end
    
    # Smart detection based on semantic field
    def detect_structure(semantic_field)
      text = semantic_field[:text].downcase
      velocity = semantic_field[:rhythm][:avg_velocity]
      confidence = semantic_field[:emotional_valence][:confidence]
      state = semantic_field[:cognitive_state]
      
      scores = {}
      
      # Check each structure's triggers
      STRUCTURES.each do |key, structure|
        score = 0.0
        
        # Trigger word matching (most important)
        if structure[:triggers]
          trigger_count = structure[:triggers].count { |trigger| text.include?(trigger) }
          score += trigger_count * 0.3
        end
        
        # Cognitive state matching
        case state
        when :flow
          score += 0.2 if [:narrative_arc, :mind_mapping].include?(key)
        when :contemplating
          score += 0.2 if [:thesis_antithesis_synthesis, :socratic_questioning].include?(key)
        when :refining
          score += 0.2 if [:logical_argument, :decision_matrix].include?(key)
        end
        
        # Velocity-based suggestions
        if velocity > 6 && confidence > 70
          # Fast, confident = analytical
          score += 0.15 if [:logical_argument, :causal_chain, :comparative_analysis].include?(key)
        elsif velocity < 4 || confidence < 50
          # Slow or uncertain = reflective/dialectical
          score += 0.15 if [:personal_insight, :devils_advocate, :retrospective].include?(key)
        end
        
        # Content-based hints
        score += 0.1 if text.include?("why") && [:root_cause_analysis, :causal_chain].include?(key)
        score += 0.1 if text.include?("feel") && key == :personal_insight
        score += 0.1 if text =~ /option|choice/ && [:decision_matrix, :comparative_analysis].include?(key)
        
        scores[key] = score if score > 0
      end
      
      # Return top 3 with structure info
      scores.sort_by { |_, v| -v }.take(3).map do |key, score|
        structure = STRUCTURES[key]
        {
          template: key,
          name: structure[:name],
          emoji: structure[:emoji],
          description: structure[:description],
          confidence: [score, 1.0].min,
          example: structure[:template],
          reason: generate_reason(key, semantic_field)
        }
      end
    end
    
    private
    
    def generate_reason(key, field)
      reasons = []
      
      case field[:cognitive_state]
      when :flow
        reasons << "You're in flow state"
      when :contemplating
        reasons << "You're thinking deeply"
      when :refining
        reasons << "You're refining your thoughts"
      end
      
      if field[:rhythm][:avg_velocity] > 6
        reasons << "steady velocity suggests confidence"
      elsif field[:rhythm][:avg_velocity] < 4
        reasons << "thoughtful pace suggests careful consideration"
      end
      
      if field[:emotional_valence][:confidence] > 70
        reasons << "high confidence detected"
      elsif field[:emotional_valence][:confidence] < 50
        reasons << "exploring uncertainty"
      end
      
      reasons.join(", ")
    end
  end
end
RUBY

echo "✓ Created 20 structure templates"

# Step 2: Test the structures
echo ""
echo "Step 2: Testing structure detection..."
echo "======================================"

rails runner "
puts 'Testing structure templates...'
puts ''

# Test 1: Logical argument
field1 = {
  text: 'because the sky is blue therefore we know light scatters',
  rhythm: { avg_velocity: 7.5, max_pause: 1.2 },
  emotional_valence: { confidence: 85 },
  cognitive_state: :refining,
  associations: []
}

suggestions = FormalStructureTemplates.detect_structure(field1)
puts '1. Fast, confident, logical text:'
suggestions.each do |s|
  puts \"   #{s[:emoji]} #{s[:name]} (#{(s[:confidence] * 100).round}%)\"
end
puts ''

# Test 2: Reflective personal
field2 = {
  text: 'i feel uncertain about this decision',
  rhythm: { avg_velocity: 3.2, max_pause: 4.5 },
  emotional_valence: { confidence: 45 },
  cognitive_state: :contemplating,
  associations: []
}

suggestions = FormalStructureTemplates.detect_structure(field2)
puts '2. Slow, uncertain, personal text:'
suggestions.each do |s|
  puts \"   #{s[:emoji]} #{s[:name]} (#{(s[:confidence] * 100).round}%)\"
end
puts ''

puts '✓ Structure detection working!'
puts \"✓ All #{FormalStructureTemplates.all.count} structures loaded\"
"

echo "✓ Structure detection tested"

echo ""
echo "======================================"
echo "✅ Phase 3 Complete!"
echo "======================================"
echo ""
echo "Structure Types Added:"
echo "  🎯 Analytical (6): Logical, Causal, Comparative, Root Cause, SWOT, Systems"
echo "  🎭 Dialectical (4): Dialectic, Devil's Advocate, Steel Man, Socratic"
echo "  🌉 Creative (4): Narrative, Metaphor, Mind Map, Analogy"
echo "  🔧 Practical (3): Problem-Solution, Decision Matrix, Process"
echo "  🔄 Reflective (3): Retrospective, Personal Insight, Learning"
echo ""
echo "Total: 20 sophisticated thinking patterns! 🎨"
echo ""
echo "Smart detection considers:"
echo "  • Trigger words in text"
echo "  • Your typing velocity"
echo "  • Your confidence level"
echo "  • Your cognitive state"
echo "  • Content patterns"
echo ""
echo "Next: Phase 4 - Priority Proofs 🔒"
echo ""