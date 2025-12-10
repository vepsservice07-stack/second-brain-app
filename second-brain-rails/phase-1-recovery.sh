#!/bin/bash
set -e

echo "======================================"
echo "🔍 Phase 1: Smart Recovery"
echo "======================================"
echo ""

PROJECT_DIR=~/Code/second-brain-app/second-brain-rails
cd "$PROJECT_DIR"

# Step 1: Check current database state
echo "Step 1: Checking current database state..."
echo "======================================"

rails runner "
puts 'Checking tables...'
puts '  Notes table: ' + (ActiveRecord::Base.connection.table_exists?('notes') ? 'EXISTS' : 'MISSING')
puts '  Users table: ' + (ActiveRecord::Base.connection.table_exists?('users') ? 'EXISTS' : 'MISSING')
puts '  CognitiveProfiles table: ' + (ActiveRecord::Base.connection.table_exists?('cognitive_profiles') ? 'EXISTS' : 'MISSING')

if ActiveRecord::Base.connection.table_exists?('notes')
  columns = ActiveRecord::Base.connection.columns('notes').map(&:name)
  puts '  Notes columns: ' + columns.join(', ')
  puts '  Has user_id: ' + (columns.include?('user_id') ? 'YES' : 'NO')
end
"

# Step 2: Remove the problematic migration
echo ""
echo "Step 2: Removing duplicate migration..."
echo "======================================"

rm -f db/migrate/202512100038*_add_user_to_notes.rb
echo "✓ Removed AddUserToNotes migration (user_id already exists)"

# Step 3: Check if CognitiveProfile migration ran
echo ""
echo "Step 3: Checking CognitiveProfiles status..."
echo "======================================"

if rails runner "exit(ActiveRecord::Base.connection.table_exists?('cognitive_profiles') ? 0 : 1)"; then
    echo "✓ CognitiveProfiles table already exists"
else
    echo "Running CognitiveProfiles migration..."
    rails db:migrate
fi

# Step 4: Ensure models exist
echo ""
echo "Step 4: Creating/updating models..."
echo "======================================"

# User model
cat > app/models/user.rb << 'RUBY'
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :notes, dependent: :destroy
  has_many :interactions, through: :notes
  has_one :cognitive_profile, dependent: :destroy
  
  after_create :create_cognitive_profile!
  
  def semantic_signature
    cognitive_profile&.analytics || {}
  end
end
RUBY

echo "✓ Updated User model"

# CognitiveProfile model
cat > app/models/cognitive_profile.rb << 'RUBY'
class CognitiveProfile < ApplicationRecord
  belongs_to :user
  
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

# Step 5: Update controllers
echo ""
echo "Step 5: Updating controllers..."
echo "======================================"

# NotesController
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

# ProfilesController
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

# Step 6: Create views
echo ""
echo "Step 6: Creating profile view..."
echo "======================================"

mkdir -p app/views/profiles

cat > app/views/profiles/show.html.erb << 'HTML'
<div class="container" style="max-width: 1200px; margin: 2rem auto; padding: 0 1rem;">
  <h1 style="font-size: 2rem; margin-bottom: 0.5rem;">Your Cognitive Profile</h1>
  <p style="color: #666; margin-bottom: 2rem;">Understanding how you think</p>
  
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin-bottom: 2rem;">
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="font-size: 2rem; margin: 0;"><%= @analytics[:total_notes] %></h3>
      <p style="color: #666; margin: 0.5rem 0 0;">Notes Created</p>
    </div>
    
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="font-size: 2rem; margin: 0;"><%= @analytics[:avg_velocity] || 'N/A' %></h3>
      <p style="color: #666; margin: 0.5rem 0 0;">Avg Velocity (chars/sec)</p>
    </div>
    
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="font-size: 2rem; margin: 0;"><%= @analytics[:avg_confidence] || 'N/A' %>%</h3>
      <p style="color: #666; margin: 0.5rem 0 0;">Avg Confidence</p>
    </div>
    
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="font-size: 2rem; margin: 0;"><%= @total_words %></h3>
      <p style="color: #666; margin: 0.5rem 0 0;">Words Written</p>
    </div>
  </div>
  
  <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 2rem;">
    <h2 style="font-size: 1.5rem; margin-bottom: 1rem;">Recent Notes</h2>
    <% if @recent_notes.any? %>
      <% @recent_notes.each do |note| %>
        <div style="padding: 1rem; border-bottom: 1px solid #eee;">
          <h3 style="margin: 0 0 0.5rem;"><%= link_to note.title, note, style: "color: #333; text-decoration: none;" %></h3>
          <p style="color: #666; margin: 0;"><%= truncate(note.content, length: 150) %></p>
        </div>
      <% end %>
    <% else %>
      <p style="color: #999;">No notes yet. <%= link_to "Create your first note", new_note_path %>!</p>
    <% end %>
  </div>
  
  <div>
    <%= link_to "← Back to Notes", notes_path, style: "display: inline-block; padding: 0.75rem 1.5rem; background: #333; color: white; text-decoration: none; border-radius: 4px;" %>
  </div>
</div>
HTML

echo "✓ Created profile view"

# Step 7: Update routes
echo ""
echo "Step 7: Updating routes..."
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

# Step 8: Create or update test user
echo ""
echo "Step 8: Ensuring test user exists..."
echo "======================================"

rails runner "
if User.exists?(email: 'test@example.com')
  user = User.find_by(email: 'test@example.com')
  puts '⚠ Test user already exists'
  
  # Ensure they have a cognitive profile
  unless user.cognitive_profile
    user.create_cognitive_profile!
    puts '✓ Created cognitive profile for existing user'
  end
else
  user = User.create!(
    email: 'test@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  puts '✓ Created new test user'
end

puts ''
puts 'User info:'
puts \"  Email: #{user.email}\"
puts \"  Cognitive profile: #{user.cognitive_profile ? 'Yes' : 'No'}\"
puts \"  Notes: #{user.notes.count}\"

# Create welcome note if none exist
if user.notes.empty?
  user.notes.create!(
    title: 'Welcome to Second Brain',
    content: 'This is your first note. Start typing and we will capture your thinking patterns.'
  )
  puts '✓ Created welcome note'
end
"

echo ""
echo "======================================"
echo "✅ Phase 1 Complete!"
echo "======================================"
echo ""
echo "What's ready:"
echo "  ✓ User authentication (Devise)"
echo "  ✓ CognitiveProfile for each user"
echo "  ✓ NotesController with authentication"
echo "  ✓ ProfilesController"
echo "  ✓ Profile view"
echo "  ✓ Test user ready"
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
echo "You'll be redirected to sign in."
echo "After login:"
echo "  • View notes at /"
echo "  • View profile at /profile"
echo "  • Create new notes"
echo ""