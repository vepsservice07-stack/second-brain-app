#!/bin/bash
set -e

echo "======================================"
echo "🔧 Phase 1 Fix: Clean Migration Setup"
echo "======================================"
echo ""

PROJECT_DIR=~/Code/second-brain-app/second-brain-rails
cd "$PROJECT_DIR"

# Step 1: Check what migrations exist
echo "Step 1: Checking existing migrations..."
echo "======================================"

echo "Current migrations:"
ls -1 db/migrate/ | grep -E "(cognitive|add_user_to_notes)" || echo "None found"

# Step 2: Remove ALL conflicting migrations
echo ""
echo "Step 2: Removing all conflicting migrations..."
echo "======================================"

rm -f db/migrate/*_create_cognitive_profiles.rb
rm -f db/migrate/*_add_user_to_notes.rb

echo "✓ Removed old migrations"

# Step 3: Create CognitiveProfile migration manually
echo ""
echo "Step 3: Creating CognitiveProfile migration..."
echo "======================================"

TIMESTAMP1=$(date +%Y%m%d%H%M%S)
sleep 1  # Ensure unique timestamp

cat > "db/migrate/${TIMESTAMP1}_create_cognitive_profiles.rb" << 'RUBY'
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

echo "✓ Created db/migrate/${TIMESTAMP1}_create_cognitive_profiles.rb"

# Step 4: Create AddUserToNotes migration
echo ""
echo "Step 4: Creating AddUserToNotes migration..."
echo "======================================"

TIMESTAMP2=$(date +%Y%m%d%H%M%S)

cat > "db/migrate/${TIMESTAMP2}_add_user_to_notes.rb" << 'RUBY'
class AddUserToNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :user, null: true, foreign_key: true
  end
end
RUBY

echo "✓ Created db/migrate/${TIMESTAMP2}_add_user_to_notes.rb"

# Step 5: Run migrations
echo ""
echo "Step 5: Running migrations..."
echo "======================================"

rails db:migrate

echo "✓ Migrations complete"

# Step 6: Verify User model has the association
echo ""
echo "Step 6: Verifying User model..."
echo "======================================"

if grep -q "has_many :notes" app/models/user.rb; then
    echo "✓ User model already updated"
else
    echo "⚠ User model needs update - doing it now..."
    cat > app/models/user.rb << 'RUBY'
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # Associations
  has_many :notes, dependent: :destroy
  has_many :interactions, through: :notes
  has_one :cognitive_profile, dependent: :destroy
  
  # Automatically create cognitive profile after user creation
  after_create :create_cognitive_profile!
  
  # Get user's semantic signature
  def semantic_signature
    cognitive_profile&.analytics || {}
  end
end
RUBY
    echo "✓ Updated User model"
fi

# Step 7: Create/verify CognitiveProfile model exists
echo ""
echo "Step 7: Creating CognitiveProfile model..."
echo "======================================"

cat > app/models/cognitive_profile.rb << 'RUBY'
class CognitiveProfile < ApplicationRecord
  belongs_to :user
  
  # Store pattern data as JSON
  store_accessor :patterns,
    :preferred_structures,
    :peak_hours,
    :avg_velocity_by_topic,
    :confidence_by_topic
  
  def analytics
    {
      total_notes: total_notes_count || 0,
      total_interactions: total_interactions_count || 0,
      avg_velocity: avg_velocity&.round(2),
      avg_confidence: avg_confidence&.round(2),
      peak_hours: peak_hours || [],
      preferred_structures: preferred_structures || []
    }
  end
end
RUBY

echo "✓ Created CognitiveProfile model"

# Step 8: Update NotesController if needed
echo ""
echo "Step 8: Checking NotesController..."
echo "======================================"

if grep -q "before_action :authenticate_user!" app/controllers/notes_controller.rb; then
    echo "✓ NotesController already has authentication"
else
    echo "⚠ Updating NotesController..."
    cat > app/controllers/notes_controller.rb << 'RUBY'
class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  
  def index
    @notes = current_user.notes.order(updated_at: :desc)
  end
  
  def show
  end
  
  def new
    @note = current_user.notes.build
  end
  
  def create
    @note = current_user.notes.build(note_params)
    
    if @note.save
      redirect_to @note, notice: 'Note created.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def update
    if @note.update(note_params)
      redirect_to @note, notice: 'Note updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @note.destroy
    redirect_to notes_path, notice: 'Note deleted.'
  end
  
  private
  
  def set_note
    @note = current_user.notes.find(params[:id])
  end
  
  def note_params
    params.require(:note).permit(:title, :content)
  end
end
RUBY
    echo "✓ Updated NotesController"
fi

# Step 9: Create ProfilesController
echo ""
echo "Step 9: Creating ProfilesController..."
echo "======================================"

cat > app/controllers/profiles_controller.rb << 'RUBY'
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @profile = current_user.cognitive_profile
    @analytics = @profile.analytics
    @recent_notes = current_user.notes.order(updated_at: :desc).limit(10)
    @total_words = current_user.notes.sum { |n| n.content.to_s.split.length }
  end
end
RUBY

echo "✓ Created ProfilesController"

# Step 10: Create profile view
echo ""
echo "Step 10: Creating profile view..."
echo "======================================"

mkdir -p app/views/profiles

cat > app/views/profiles/show.html.erb << 'HTML'
<div class="profile-container">
  <h1>Your Cognitive Profile</h1>
  
  <div class="stats-grid">
    <div class="stat-card">
      <h3><%= @analytics[:total_notes] %></h3>
      <p>Notes Created</p>
    </div>
    
    <div class="stat-card">
      <h3><%= @analytics[:avg_velocity] || 'N/A' %></h3>
      <p>Avg Velocity</p>
    </div>
    
    <div class="stat-card">
      <h3><%= @analytics[:avg_confidence] || 'N/A' %>%</h3>
      <p>Avg Confidence</p>
    </div>
    
    <div class="stat-card">
      <h3><%= @total_words %></h3>
      <p>Words Written</p>
    </div>
  </div>
  
  <div class="profile-section">
    <h2>Recent Notes</h2>
    <% @recent_notes.each do |note| %>
      <div class="note-card">
        <h3><%= link_to note.title, note %></h3>
        <p><%= truncate(note.content, length: 150) %></p>
      </div>
    <% end %>
  </div>
  
  <div class="actions">
    <%= link_to "Back to Notes", notes_path, class: "btn" %>
  </div>
</div>
HTML

echo "✓ Created profile view"

# Step 11: Update routes
echo ""
echo "Step 11: Updating routes..."
echo "======================================"

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  devise_for :users
  
  get "up" => "rails/health#show", as: :rails_health_check
  
  root "notes#index"
  
  resources :notes
  resource :profile, only: [:show]
end
RUBY

echo "✓ Updated routes"

# Step 12: Test in console
echo ""
echo "Step 12: Creating test user..."
echo "======================================"

rails runner "
if User.exists?(email: 'test@example.com')
  puts '⚠ Test user already exists'
  user = User.find_by(email: 'test@example.com')
else
  user = User.create!(
    email: 'test@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts '✓ Created test user'
end

puts \"Email: #{user.email}\"
puts \"Cognitive profile: #{user.cognitive_profile ? 'Yes' : 'No'}\"

if user.notes.any?
  puts \"Notes: #{user.notes.count}\"
else
  note = user.notes.create!(
    title: 'Welcome to Second Brain',
    content: 'This is your first note. Start typing and we will capture your thinking patterns.'
  )
  puts \"✓ Created welcome note\"
end
"

echo ""
echo "======================================"
echo "✅ Phase 1 Complete!"
echo "======================================"
echo ""
echo "Setup summary:"
echo "  ✓ Devise authentication installed"
echo "  ✓ User model with associations"
echo "  ✓ CognitiveProfile for each user"
echo "  ✓ ProfilesController + view"
echo "  ✓ NotesController requires login"
echo "  ✓ Routes updated"
echo ""
echo "Test credentials:"
echo "  Email: test@example.com"
echo "  Password: password123"
echo ""
echo "Start server:"
echo "  bin/rails server"
echo ""
echo "Then visit:"
echo "  http://localhost:3000"
echo ""
echo "You'll be redirected to sign in."
echo "After login, you can:"
echo "  • View notes at /"
echo "  • View profile at /profile"
echo "  • Create new notes"
echo ""