#!/bin/bash
set -e

echo "======================================"
echo "🔧 Phase 1 Fix: Migration Timestamps"
echo "======================================"
echo ""

PROJECT_DIR=~/Code/second-brain-app/second-brain-rails
cd "$PROJECT_DIR"

# Step 1: Clean up duplicate migrations
echo "Step 1: Cleaning up duplicate migrations..."
echo "======================================"

# Find and remove our newly created migrations
ls -la db/migrate/ | grep "20251210"

echo ""
echo "Removing duplicate migrations..."
rm -f db/migrate/202512100533*_create_cognitive_profiles.rb
rm -f db/migrate/202512100533*_add_user_to_notes.rb

echo "✓ Cleaned up duplicates"

# Step 2: Create migrations with proper timestamps
echo ""
echo "Step 2: Creating migrations with unique timestamps..."
echo "======================================"

# Use Rails generators which handle timestamps properly
rails generate model CognitiveProfile user:references patterns:jsonb avg_velocity:float avg_confidence:float total_notes_count:integer total_interactions_count:integer

# Add user to notes
rails generate migration AddUserToNotes user:references

echo "✓ Created migrations"

# Step 3: Update the generated migrations
echo ""
echo "Step 3: Updating migration content..."
echo "======================================"

# Find the cognitive profile migration
COGNITIVE_MIGRATION=$(ls -1 db/migrate/*_create_cognitive_profiles.rb | tail -1)

cat > "$COGNITIVE_MIGRATION" << 'RUBY'
class CreateCognitiveProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :cognitive_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.json :patterns, default: {}, null: false
      
      # Computed fields for quick access
      t.float :avg_velocity
      t.float :avg_confidence
      t.integer :total_notes_count, default: 0
      t.integer :total_interactions_count, default: 0
      
      t.timestamps
    end
    
    add_index :cognitive_profiles, :patterns
  end
end
RUBY

echo "✓ Updated CognitiveProfile migration"

# Find the add user to notes migration
USER_NOTES_MIGRATION=$(ls -1 db/migrate/*_add_user_to_notes.rb | tail -1)

cat > "$USER_NOTES_MIGRATION" << 'RUBY'
class AddUserToNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :user, null: true, foreign_key: true
    
    # For existing notes without user, we'll handle in console
  end
end
RUBY

echo "✓ Updated AddUserToNotes migration"

# Step 4: Now run migrations
echo ""
echo "Step 4: Running migrations..."
echo "======================================"

rails db:migrate

echo "✓ Migrations complete"

# Step 5: Test in console
echo ""
echo "Step 5: Testing setup..."
echo "======================================"

rails runner "
# Create test user
user = User.create!(
  email: 'test@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)

puts \"✓ Created test user: #{user.email}\"
puts \"✓ Cognitive profile: #{user.cognitive_profile.present? ? 'Created' : 'Missing'}\"

# Create test note
note = user.notes.create!(
  title: 'First Note',
  content: 'Testing the authentication system'
)

puts \"✓ Created test note: #{note.title}\"
puts \"\"
puts \"Test credentials:\"
puts \"  Email: test@example.com\"
puts \"  Password: password123\"
"

echo ""
echo "======================================"
echo "✅ Phase 1 Complete!"
echo "======================================"
echo ""
echo "What was created:"
echo "  ✓ User authentication (Devise)"
echo "  ✓ CognitiveProfile model"
echo "  ✓ User → Notes association"
echo "  ✓ ProfilesController + view"
echo "  ✓ Test user created"
echo ""
echo "Test credentials:"
echo "  Email: test@example.com"
echo "  Password: password123"
echo ""
echo "Start the server:"
echo "  bin/rails server"
echo ""
echo "Then visit:"
echo "  http://localhost:3000"
echo ""