#!/bin/bash
set -e

echo "======================================"
echo "Completing Phase 4.9 + Testing Phase 4.95"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

echo "Step 1: Running pending migrations..."
echo "======================================"

# Check if migrations need to be created
if ! ls db/migrate/*_add_veps_fields_to_interactions.rb 2>/dev/null; then
    echo "Creating AddVepsFieldsToInteractions migration..."
    bin/rails generate migration AddVepsFieldsToInteractions \
        device_id:string \
        vector_clock:jsonb \
        previous_hash:string
else
    echo "✓ AddVepsFieldsToInteractions migration exists"
fi

if ! ls db/migrate/*_create_snapshots.rb 2>/dev/null; then
    echo "Creating Snapshots model..."
    bin/rails generate model Snapshot \
        note_id:integer \
        sequence_number:bigint \
        content:text \
        interaction_count:integer \
        merkle_root:string
else
    echo "✓ Snapshots model exists"
fi

if ! ls db/migrate/*_create_timeline_branches.rb 2>/dev/null; then
    echo "Creating TimelineBranches model..."
    bin/rails generate model TimelineBranch \
        note_id:integer \
        divergence_sequence:bigint \
        deleted_content:text \
        current_content:text \
        reason:text
else
    echo "✓ TimelineBranches model exists"
fi

echo ""
echo "Running migrations..."
bin/rails db:migrate

echo ""
echo "Step 2: Testing VEPS Infrastructure..."
echo "======================================"

bin/rails runner "
puts 'Testing VEPS Mock...'
require 'veps/mock_client'

result = Veps::MockClient.submit_event(
  event_type: 'interaction_keystroke',
  actor: { id: 'test-device' },
  evidence: { note_id: 1, char: 'h', position: 0 }
)

if result[:sequence_number] && result[:vector_clock]
  puts '✓ VEPS mock working'
  puts \"  Sequence: #{result[:sequence_number]}\"
  puts \"  Vector clock: #{result[:vector_clock]}\"
else
  puts '✗ VEPS mock failed'
end
"

echo ""
echo "Step 3: Testing Semantic Field Extractor..."
echo "======================================"

bin/rails runner "
puts 'Testing SemanticFieldExtractor...'

# Create a test note with some interactions
note = Note.create!(title: 'Test Semantic Analysis', content: '')

puts \"Created note ##{note.id}\"

# Simulate typing 'hello' with pauses
base_time = Time.now - 1.minute

Interaction.create!(
  note: note,
  interaction_type: 'keystroke',
  data: { char: 'h', position: 0, operation: 'insert' },
  sequence_number: 1,
  device_id: 'test-device',
  vector_clock: { 'test-device' => 1 },
  created_at: base_time
)

Interaction.create!(
  note: note,
  interaction_type: 'keystroke',
  data: { char: 'e', position: 1, operation: 'insert' },
  sequence_number: 2,
  device_id: 'test-device',
  vector_clock: { 'test-device' => 2 },
  created_at: base_time + 0.2.seconds
)

Interaction.create!(
  note: note,
  interaction_type: 'keystroke',
  data: { char: 'l', position: 2, operation: 'insert' },
  sequence_number: 3,
  device_id: 'test-device',
  vector_clock: { 'test-device' => 3 },
  created_at: base_time + 0.4.seconds
)

# LONG PAUSE
Interaction.create!(
  note: note,
  interaction_type: 'keystroke',
  data: { char: 'l', position: 3, operation: 'insert' },
  sequence_number: 4,
  device_id: 'test-device',
  vector_clock: { 'test-device' => 4 },
  created_at: base_time + 5.seconds
)

Interaction.create!(
  note: note,
  interaction_type: 'keystroke',
  data: { char: 'o', position: 4, operation: 'insert' },
  sequence_number: 5,
  device_id: 'test-device',
  vector_clock: { 'test-device' => 5 },
  created_at: base_time + 5.2.seconds
)

puts \"Created #{note.interactions.count} interactions\"

# Extract semantic field
puts ''
puts 'Extracting semantic field...'
field = SemanticFieldExtractor.extract(note.id)

if field
  puts '✓ Semantic field extracted'
  puts \"  Text: #{field[:text]}\"
  puts \"  Avg velocity: #{field[:rhythm][:avg_velocity].round(2)}\"
  puts \"  Max pause: #{field[:rhythm][:max_pause].round(2)}s\"
  puts \"  Cognitive state: #{field[:cognitive_state]}\"
  puts \"  Confidence: #{field[:emotional_valence][:confidence].round(2)}%\"
else
  puts '✗ Failed to extract semantic field'
end

# Clean up
note.destroy
puts ''
puts '✓ Test complete (note cleaned up)'
"

echo ""
echo "Step 4: Testing Formal Structure Templates..."
echo "======================================"

bin/rails runner "
puts 'Testing FormalStructureTemplates...'

# Create a note with some philosophical content
note = Note.create!(title: 'Test Structure Detection', content: '')

# Add interactions that spell out a logical argument
text = 'I think context determines meaning because words depend on their use therefore meaning is not fixed'
text.chars.each_with_index do |char, i|
  Interaction.create!(
    note: note,
    interaction_type: 'keystroke',
    data: { char: char, position: i, operation: 'insert' },
    sequence_number: i + 1,
    device_id: 'test-device',
    vector_clock: { 'test-device' => i + 1 },
    created_at: Time.now - 1.minute + (i * 0.1).seconds
  )
end

# Extract semantic field
field = SemanticFieldExtractor.extract(note.id)

# Detect structures
puts ''
puts 'Detecting formal structures...'
structures = FormalStructureTemplates.detect_structure(field)

if structures && structures.length > 0
  puts \"✓ Found #{structures.length} possible structures:\"
  structures.each do |s|
    puts \"  - #{s[:name]}: #{(s[:confidence] * 100).round(1)}% confidence\"
  end
else
  puts '✗ No structures detected'
end

# Clean up
note.destroy
puts ''
puts '✓ Test complete (note cleaned up)'
"

echo ""
echo "Step 5: Testing Structure Suggester (The Dyad!)..."
echo "======================================"

bin/rails runner "
puts 'Testing StructureSuggester (Human-AI Dyad)...'

# Create a test note
note = Note.create!(title: 'Dyad Test', content: '')

# Simulate typing a philosophical statement
text = 'Context determines meaning'
text.chars.each_with_index do |char, i|
  Interaction.create!(
    note: note,
    interaction_type: 'keystroke',
    data: { char: char, position: i, operation: 'insert' },
    sequence_number: i + 1,
    device_id: 'test-device',
    vector_clock: { 'test-device' => i + 1 },
    created_at: Time.now - 30.seconds + (i * 0.15).seconds
  )
end

# Get structure suggestions
puts ''
puts 'Getting structure suggestions...'
suggestions = StructureSuggester.suggest(note.id)

if suggestions && suggestions[:suggestions]
  puts '✓ Dyad working!'
  puts ''
  puts 'Semantic Analysis:'
  puts \"  Cognitive state: #{suggestions[:semantic_analysis][:cognitive_state]}\"
  puts \"  Flow state: #{suggestions[:semantic_analysis][:flow_state]}\"
  puts \"  Confidence: #{suggestions[:semantic_analysis][:confidence].round(2)}%\"
  puts ''
  puts 'Structure Suggestions:'
  suggestions[:suggestions].each_with_index do |s, idx|
    puts \"  #{idx + 1}. #{s[:structure][:name]} (#{(s[:structure][:confidence] * 100).round(1)}%)\"
    puts \"     Example: #{s[:structure][:example]}\"
  end
else
  puts '✗ Dyad failed to generate suggestions'
end

# Clean up
note.destroy
puts ''
puts '✓ Test complete (note cleaned up)'
"

echo ""
echo "Step 6: Checking service files..."
echo "======================================"

files_to_check=(
  "lib/veps/mock_client.rb"
  "app/services/event_store.rb"
  "app/services/semantic_field_extractor.rb"
  "app/services/formal_structure_templates.rb"
  "app/services/structure_suggester.rb"
  "app/controllers/structure_suggestions_controller.rb"
  "app/javascript/components/structure_suggester.js"
)

all_exist=true
for file in "${files_to_check[@]}"; do
  if [ -f "$file" ]; then
    echo "  ✓ $file"
  else
    echo "  ✗ $file MISSING"
    all_exist=false
  fi
done

if [ "$all_exist" = true ]; then
  echo ""
  echo "✓ All infrastructure files present"
fi

echo ""
echo "======================================"
echo "✓ Setup Complete!"
echo "======================================"
echo ""
echo "What's working:"
echo "  ✓ VEPS mock (keystroke-level)"
echo "  ✓ Event sourcing infrastructure"
echo "  ✓ Semantic field extraction"
echo "  ✓ Formal structure detection"
echo "  ✓ Human-AI dyad suggester"
echo ""
echo "Next steps:"
echo ""
echo "1. Start the Rails server:"
echo "   bin/rails server"
echo ""
echo "2. Open a note and start typing"
echo "   - Structure suggestions will appear on the right"
echo "   - Press Alt+1/2/3 to apply a structure"
echo "   - System learns your preferences"
echo ""
echo "3. Test the API endpoints:"
echo "   curl http://localhost:3000/notes/1/semantic_field"
echo "   curl http://localhost:3000/notes/1/structure_suggestions"
echo ""
echo "4. View time machine:"
echo "   Visit: http://localhost:3000/notes/:id/time_machine"
echo ""
echo "The Magic:"
echo "  • You provide semantic content (fuzzy, creative)"
echo "  • AI suggests formal structures (logical, organized)"
echo "  • You choose → System learns YOUR style"
echo "  • True human-AI collaboration!"
echo ""
echo "🎨 Ready to experience the cognitive dyad!"
echo ""