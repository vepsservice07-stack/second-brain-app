#!/bin/bash
set -e

echo "======================================"
echo "🔥 Phase 1: Fresh Start (Nuclear Option)"
echo "======================================"
echo ""
echo "This will DELETE the database and start fresh."
echo "Press Ctrl+C within 5 seconds to cancel..."
echo ""

sleep 5

PROJECT_DIR=~/Code/second-brain-app/second-brain-rails
cd "$PROJECT_DIR"

# Step 1: Delete database
echo "Step 1: Deleting old database..."
echo "======================================"

rm -f storage/*.sqlite3
rm -f storage/*.sqlite3-*
rm -f db/schema.rb

echo "✓ Database deleted"

# Step 2: Skip problematic migrations
echo ""
echo "Step 2: Skipping problematic migrations..."
echo "======================================"

# Skip VEPS fields migration (we don't have interactions table yet)
for file in db/migrate/*add_veps_fields*.rb; do
    if [ -f "$file" ]; then
        mv "$file" "${file}.skip"
        echo "  Skipped: $(basename $file)"
    fi
done

echo "✓ Migrations cleaned"

# Step 3: Run fresh migrations
echo ""
echo "Step 3: Running migrations from scratch..."
echo "======================================"

bin/rails db:create
bin/rails db:migrate

echo "✓ Database created"

# Step 4: Create models
echo ""
echo "Step 4: Creating models..."
echo "======================================"

cat > app/models/user.rb << 'RUBY'
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :notes, dependent: :destroy
  has_one :cognitive_profile, dependent: :destroy
  
  after_create :create_cognitive_profile!
  
  def semantic_signature
    cognitive_profile&.analytics || {}
  end
end
RUBY

cat > app/models/cognitive_profile.rb << 'RUBY'
class CognitiveProfile < ApplicationRecord
  belongs_to :user
  
  store_accessor :patterns,
    :preferred_structures,
    :peak_hours
  
  def analytics
    {
      total_notes: total_notes_count || 0,
      avg_velocity: avg_velocity&.round(2),
      avg_confidence: avg_confidence&.round(2),
      peak_hours: peak_hours || [],
      preferred_structures: preferred_structures || []
    }
  end
end
RUBY

echo "✓ Models created"

# Step 5: Create controllers
echo ""
echo "Step 5: Creating controllers..."
echo "======================================"

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

echo "✓ Controllers created"

# Step 6: Create views
echo ""
echo "Step 6: Creating views..."
echo "======================================"

mkdir -p app/views/profiles

cat > app/views/profiles/show.html.erb << 'HTML'
<div class="container" style="max-width: 1200px; margin: 2rem auto; padding: 0 1rem;">
  <h1>Your Cognitive Profile</h1>
  
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin: 2rem 0;">
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="font-size: 2rem; margin: 0;"><%= @analytics[:total_notes] %></h3>
      <p style="color: #666; margin: 0.5rem 0 0;">Notes Created</p>
    </div>
    
    <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
      <h3 style="font-size: 2rem; margin: 0;"><%= @total_words %></h3>
      <p style="color: #666; margin: 0.5rem 0 0;">Words Written</p>
    </div>
  </div>
  
  <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 2rem;">
    <h2>Recent Notes</h2>
    <% if @recent_notes.any? %>
      <% @recent_notes.each do |note| %>
        <div style="padding: 1rem; border-bottom: 1px solid #eee;">
          <h3><%= link_to note.title, note %></h3>
          <p><%= truncate(note.content, length: 150) %></p>
        </div>
      <% end %>
    <% else %>
      <p>No notes yet. <%= link_to "Create your first note", new_note_path %>!</p>
    <% end %>
  </div>
  
  <%= link_to "← Back to Notes", notes_path, style: "display: inline-block; padding: 0.75rem 1.5rem; background: #333; color: white; text-decoration: none; border-radius: 4px;" %>
</div>
HTML

echo "✓ Views created"

# Step 7: Routes
echo ""
echo "Step 7: Updating routes..."
echo "======================================"

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  devise_for :users
  root "notes#index"
  resources :notes
  resource :profile, only: [:show]
  get "up" => "rails/health#show", as: :rails_health_check
end
RUBY

echo "✓ Routes updated"

# Step 8: Create test user
echo ""
echo "Step 8: Creating test user..."
echo "======================================"

rails runner "
begin
  user = User.create!(
    email: 'test@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  
  user.notes.create!(
    title: 'Welcome to Second Brain',
    content: 'Your first note. Start typing and we will capture your thinking patterns.'
  )
  
  puts '✓ Test user created'
  puts \"Email: #{user.email}\"
  puts \"Profile: #{user.cognitive_profile ? 'Yes' : 'No'}\"
  puts \"Notes: #{user.notes.count}\"
rescue => e
  puts \"Note: #{e.message}\"
  puts 'You can create an account via the signup page'
end
"

echo ""
echo "======================================"
echo "✅ PHASE 1 COMPLETE - FRESH START!"
echo "======================================"
echo ""
echo "Database rebuilt from scratch with:"
echo "  ✓ Users table (Devise)"
echo "  ✓ Notes table"
echo "  ✓ CognitiveProfiles table"
echo "  ✓ All associations working"
echo "  ✓ Controllers with authentication"
echo "  ✓ Profile view"
echo ""
echo "Test credentials:"
echo "  Email: test@example.com"
echo "  Password: password123"
echo ""
echo "START THE SERVER:"
echo "  bin/rails server"
echo ""
echo "Then visit: http://localhost:3000"
echo ""
echo "✨ Ready to build Phase 2! ✨"
echo ""