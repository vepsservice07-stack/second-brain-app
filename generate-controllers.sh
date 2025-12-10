#!/bin/bash
# Second Brain - Generate Controllers and Views
# Creates the controllers and basic UI for notes management
# Usage: ./generate-controllers.sh

echo "========================================"
echo "  Generating Controllers and Views"
echo "========================================"
echo ""

# Check if we're in the Rails app directory
if [ ! -f "bin/rails" ]; then
    if [ -d "second-brain-rails" ]; then
        echo "Entering Rails app directory..."
        cd second-brain-rails
    else
        echo "❌ Error: Not in Rails app directory"
        exit 1
    fi
fi

echo "Generating Notes controller..."
bin/rails generate controller Notes index show new edit

echo "Generating Tags controller..."
bin/rails generate controller Tags index

echo "Generating Home controller..."
bin/rails generate controller Home index

echo ""
echo "✅ Controllers generated"
echo ""

echo "Setting up routes..."

# Update routes.rb
cat > config/routes.rb << 'EOF'
Rails.application.routes.draw do
  # Root path
  root "home#index"

  # Notes management
  resources :notes do
    member do
      post :restore  # For restoring soft-deleted notes
    end
  end
  
  # Tags management
  resources :tags, only: [:index, :create, :destroy]
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
EOF

echo "✅ Routes configured"
echo ""

echo "Creating Home controller..."

cat > app/controllers/home_controller.rb << 'EOF'
class HomeController < ApplicationController
  def index
    @recent_notes = Note.active.order(updated_at: :desc).limit(5)
    @note_count = Note.active.count
    @tag_count = Tag.count
  end
end
EOF

echo "✅ Home controller created"
echo ""

echo "Creating Notes controller..."

cat > app/controllers/notes_controller.rb << 'EOF'
class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update, :destroy, :restore]

  def index
    @notes = Note.active.order(updated_at: :desc).page(params[:page])
  end

  def show
    @tags = @note.tags
    @attachments = @note.attachments
    @linked_notes = @note.linked_notes
  end

  def new
    @note = Note.new
    @all_tags = Tag.all
  end

  def create
    @note = Note.new(note_params)
    
    if @note.save
      # Handle tag associations
      if params[:tag_ids].present?
        params[:tag_ids].each do |tag_id|
          @note.tags << Tag.find(tag_id) unless tag_id.blank?
        end
      end
      
      redirect_to @note, notice: 'Note created successfully.'
    else
      @all_tags = Tag.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @all_tags = Tag.all
  end

  def update
    if @note.update(note_params)
      # Update tag associations
      @note.tags.clear
      if params[:tag_ids].present?
        params[:tag_ids].each do |tag_id|
          @note.tags << Tag.find(tag_id) unless tag_id.blank?
        end
      end
      
      redirect_to @note, notice: 'Note updated successfully.'
    else
      @all_tags = Tag.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.soft_delete
    redirect_to notes_path, notice: 'Note deleted.'
  end

  def restore
    @note.update(deleted_at: nil)
    redirect_to @note, notice: 'Note restored.'
  end

  private

  def set_note
    @note = Note.find(params[:id])
  end

  def note_params
    params.require(:note).permit(:title, :content)
  end
end
EOF

echo "✅ Notes controller created"
echo ""

echo "Creating Tags controller..."

cat > app/controllers/tags_controller.rb << 'EOF'
class TagsController < ApplicationController
  def index
    @tags = Tag.all.order(:name)
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    
    if @tag.save
      redirect_to tags_path, notice: 'Tag created successfully.'
    else
      @tags = Tag.all.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to tags_path, notice: 'Tag deleted.'
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :color)
  end
end
EOF

echo "✅ Tags controller created"
echo ""

echo "========================================"
echo "  Controller Generation Complete!"
echo "========================================"
echo ""
echo "Controllers created:"
echo "  🏠 Home - Dashboard"
echo "  📝 Notes - CRUD operations"
echo "  🏷️  Tags - Tag management"
echo ""
echo "Next: Run './generate-views.sh' to create the UI"
echo ""