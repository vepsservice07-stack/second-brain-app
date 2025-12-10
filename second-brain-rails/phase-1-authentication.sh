#!/bin/bash
set -e

echo "======================================"
echo "🚀 Phase 1: Multi-User Authentication"
echo "======================================"
echo ""

PROJECT_DIR=~/Code/second-brain-app/second-brain-rails
cd "$PROJECT_DIR"

# Step 1: Add Devise to Gemfile
echo "Step 1: Adding Devise gem..."
echo "======================================"

if ! grep -q "gem 'devise'" Gemfile; then
    echo "gem 'devise'" >> Gemfile
    echo "✓ Added devise to Gemfile"
else
    echo "✓ Devise already in Gemfile"
fi

# Step 2: Bundle install
echo ""
echo "Step 2: Installing gems..."
echo "======================================"
bundle install

# Step 3: Install Devise
echo ""
echo "Step 3: Installing Devise..."
echo "======================================"
rails generate devise:install

# Step 4: Generate User model
echo ""
echo "Step 4: Creating User model..."
echo "======================================"
rails generate devise User

# Step 5: Create CognitiveProfile model
echo ""
echo "Step 5: Creating CognitiveProfile model..."
echo "======================================"

cat > db/migrate/$(date +%Y%m%d%H%M%S)_create_cognitive_profiles.rb << 'RUBY'
class CreateCognitiveProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :cognitive_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.jsonb :patterns, default: {}, null: false
      
      # Computed fields for quick access
      t.float :avg_velocity
      t.float :avg_confidence
      t.integer :total_notes_count, default: 0
      t.integer :total_interactions_count, default: 0
      
      t.timestamps
    end
    
    add_index :cognitive_profiles, :patterns, using: :gin
  end
end
RUBY

echo "✓ Created CognitiveProfile migration"

# Step 6: Create CognitiveProfile model file
echo ""
echo "Step 6: Creating CognitiveProfile model..."
echo "======================================"

cat > app/models/cognitive_profile.rb << 'RUBY'
# Stores and analyzes each user's unique thinking patterns
# This is the "cognitive fingerprint" that makes Second Brain personal
class CognitiveProfile < ApplicationRecord
  belongs_to :user
  
  # Store pattern data as JSON
  store_accessor :patterns,
    :preferred_structures,      # [:dialectic, :comparison, ...]
    :peak_hours,               # [14, 15, 16] for 2-4pm
    :avg_velocity_by_topic,    # { philosophy: 6.2, tech: 8.1 }
    :confidence_by_topic,      # { philosophy: 72, tech: 85 }
    :structure_evolution,      # How preferences changed over time
    :influence_network,        # Which notes lead to breakthroughs
    :flow_triggers            # What conditions lead to flow state
  
  # Update profile with new interaction data
  def update_from_interaction!(interaction)
    semantic_field = SemanticFieldExtractor.extract(interaction.note_id)
    return unless semantic_field
    
    # Update velocity stats
    update_velocity_stats(semantic_field)
    
    # Update confidence stats
    update_confidence_stats(semantic_field)
    
    # Update structure preferences if structure was applied
    if interaction.interaction_type == 'structure_applied'
      update_structure_preferences(interaction.data['structure_type'])
    end
    
    # Update peak hours
    update_peak_hours(interaction.created_at.hour)
    
    save!
  end
  
  # Get personalized structure suggestions
  def suggest_structures_for(semantic_field)
    # Use learned preferences to rank structures
    base_suggestions = FormalStructureTemplates.detect_structure(semantic_field)
    
    # Boost structures user prefers
    if preferred_structures.present?
      base_suggestions.each do |suggestion|
        structure_key = suggestion[:template]
        if preferred_structures.include?(structure_key.to_s)
          suggestion[:confidence] *= 1.2  # 20% boost
          suggestion[:reason] = "#{suggestion[:reason]} (You prefer this structure)"
        end
      end
    end
    
    base_suggestions.sort_by { |s| -s[:confidence] }.take(3)
  end
  
  # Analytics for dashboard
  def analytics
    {
      total_notes: total_notes_count,
      total_interactions: total_interactions_count,
      avg_velocity: avg_velocity&.round(2),
      avg_confidence: avg_confidence&.round(2),
      peak_hours: peak_hours || [],
      preferred_structures: preferred_structures || [],
      strongest_topics: confidence_by_topic&.sort_by { |_, v| -v }&.take(3)&.to_h || {}
    }
  end
  
  private
  
  def update_velocity_stats(semantic_field)
    velocity = semantic_field[:rhythm][:avg_velocity]
    
    if self.avg_velocity.nil?
      self.avg_velocity = velocity
    else
      # Exponential moving average (more weight on recent)
      self.avg_velocity = self.avg_velocity * 0.9 + velocity * 0.1
    end
  end
  
  def update_confidence_stats(semantic_field)
    confidence = semantic_field[:emotional_valence][:confidence]
    
    if self.avg_confidence.nil?
      self.avg_confidence = confidence
    else
      self.avg_confidence = self.avg_confidence * 0.9 + confidence * 0.1
    end
  end
  
  def update_structure_preferences(structure_type)
    prefs = self.preferred_structures || []
    prefs << structure_type
    
    # Keep top 5 most used
    self.preferred_structures = prefs.group_by(&:itself)
      .transform_values(&:count)
      .sort_by { |_, count| -count }
      .take(5)
      .map(&:first)
  end
  
  def update_peak_hours(hour)
    hours = self.peak_hours || []
    hours << hour
    
    # Keep rolling window of last 100 hours
    hours = hours.last(100)
    
    # Find most common hours
    self.peak_hours = hours.group_by(&:itself)
      .transform_values(&:count)
      .sort_by { |_, count| -count }
      .take(3)
      .map(&:first)
  end
end
RUBY

echo "✓ Created CognitiveProfile model"

# Step 7: Update User model
echo ""
echo "Step 7: Updating User model..."
echo "======================================"

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
  
  # Update cognitive profile from latest activity
  def update_cognitive_profile!
    return unless cognitive_profile
    
    # Recalculate from all interactions
    interactions.find_each do |interaction|
      cognitive_profile.update_from_interaction!(interaction)
    end
  end
end
RUBY

echo "✓ Updated User model"

# Step 8: Add user_id to notes
echo ""
echo "Step 8: Adding user_id to notes..."
echo "======================================"

cat > db/migrate/$(date +%Y%m%d%H%M%S)_add_user_to_notes.rb << 'RUBY'
class AddUserToNotes < ActiveRecord::Migration[8.0]
  def change
    add_reference :notes, :user, null: true, foreign_key: true
    
    # For existing notes, we'll need to assign them to a default user
    # Or handle this manually in console
  end
end
RUBY

echo "✓ Created migration for user_id on notes"

# Step 9: Update NotesController
echo ""
echo "Step 9: Updating NotesController..."
echo "======================================"

cat > app/controllers/notes_controller.rb << 'RUBY'
class NotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  
  def index
    @notes = current_user.notes
      .order(updated_at: :desc)
      .limit(50)
  end
  
  def show
    # Record that user viewed this note (for association tracking)
    Interaction.create!(
      note: @note,
      interaction_type: 'note_viewed',
      data: { viewed_at: Time.current },
      sequence_number: @note.next_sequence_number
    )
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
      # Update cognitive profile
      current_user.cognitive_profile&.update_from_interaction!(@note.interactions.last)
      
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

# Step 10: Create ProfilesController
echo ""
echo "Step 10: Creating ProfilesController..."
echo "======================================"

cat > app/controllers/profiles_controller.rb << 'RUBY'
class ProfilesController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @profile = current_user.cognitive_profile
    @analytics = @profile.analytics
    
    # Get recent activity
    @recent_notes = current_user.notes
      .order(updated_at: :desc)
      .limit(10)
    
    # Calculate additional stats
    @total_words = current_user.notes.sum { |n| n.content.to_s.split.length }
    @total_characters = current_user.notes.sum { |n| n.content.to_s.length }
  end
  
  def update
    @profile = current_user.cognitive_profile
    
    # Recalculate profile from scratch
    current_user.update_cognitive_profile!
    
    redirect_to profile_path, notice: 'Profile updated.'
  end
end
RUBY

echo "✓ Created ProfilesController"

# Step 11: Update routes
echo ""
echo "Step 11: Updating routes..."
echo "======================================"

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  # Devise authentication
  devise_for :users
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Root
  root "notes#index"
  
  # Notes (main resource)
  resources :notes do
    member do
      get :semantic_field
      get :structure_suggestions
      post :apply_structure
      get :time_machine
      get 'at_sequence/:sequence', to: 'notes#at_sequence', as: :at_sequence
    end
    
    resources :interactions, only: [:create, :index]
  end
  
  # User profile
  resource :profile, only: [:show, :update]
  
  # Structure suggestions API
  namespace :api do
    resources :structure_suggestions, only: [:create]
  end
end
RUBY

echo "✓ Updated routes"

# Step 12: Create profile view
echo ""
echo "Step 12: Creating profile view..."
echo "======================================"

mkdir -p app/views/profiles

cat > app/views/profiles/show.html.erb << 'HTML'
<div class="profile-container">
  <div class="profile-header">
    <h1>Your Cognitive Profile</h1>
    <p class="subtitle">Understanding how you think</p>
  </div>
  
  <div class="stats-grid">
    <div class="stat-card">
      <h3><%= @analytics[:total_notes] %></h3>
      <p>Notes Created</p>
    </div>
    
    <div class="stat-card">
      <h3><%= @analytics[:avg_velocity] %></h3>
      <p>Avg Velocity (chars/sec)</p>
    </div>
    
    <div class="stat-card">
      <h3><%= @analytics[:avg_confidence] %>%</h3>
      <p>Avg Confidence</p>
    </div>
    
    <div class="stat-card">
      <h3><%= number_to_human(@total_words) %></h3>
      <p>Words Written</p>
    </div>
  </div>
  
  <div class="profile-section">
    <h2>🌟 Your Peak Hours</h2>
    <% if @analytics[:peak_hours].any? %>
      <div class="peak-hours">
        <% @analytics[:peak_hours].each do |hour| %>
          <span class="hour-badge"><%= hour %>:00 - <%= hour + 1 %>:00</span>
        <% end %>
      </div>
      <p class="insight">You think best during these hours</p>
    <% else %>
      <p class="empty">Write more to discover your peak hours</p>
    <% end %>
  </div>
  
  <div class="profile-section">
    <h2>🎭 Preferred Structures</h2>
    <% if @analytics[:preferred_structures].any? %>
      <div class="structures-list">
        <% @analytics[:preferred_structures].each do |structure| %>
          <div class="structure-item">
            <span class="structure-name"><%= structure.to_s.titleize %></span>
          </div>
        <% end %>
      </div>
    <% else %>
      <p class="empty">Apply structures to notes to see your preferences</p>
    <% end %>
  </div>
  
  <div class="profile-section">
    <h2>📚 Recent Notes</h2>
    <div class="recent-notes">
      <% @recent_notes.each do |note| %>
        <div class="note-card">
          <h3><%= link_to note.title, note %></h3>
          <p class="excerpt"><%= truncate(note.content, length: 150) %></p>
          <span class="timestamp"><%= time_ago_in_words(note.updated_at) %> ago</span>
        </div>
      <% end %>
    </div>
  </div>
  
  <div class="profile-actions">
    <%= button_to "Refresh Profile", profile_path, method: :patch, class: "btn-primary" %>
  </div>
</div>
HTML

echo "✓ Created profile view"

# Step 13: Add authentication helpers
echo ""
echo "Step 13: Updating ApplicationController..."
echo "======================================"

cat > app/controllers/application_controller.rb << 'RUBY'
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
RUBY

echo "✓ Updated ApplicationController"

# Step 14: Run migrations
echo ""
echo "Step 14: Running migrations..."
echo "======================================"

rails db:migrate

# Step 15: Test in console
echo ""
echo "Step 15: Testing in console..."
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
  content: 'Testing the system'
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
echo "  ✓ User → Notes → Interactions associations"
echo "  ✓ ProfilesController + view"
echo "  ✓ Updated NotesController with auth"
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
echo "Next: Phase 2 - UI/UX (The Therapist Aesthetic)"
echo ""