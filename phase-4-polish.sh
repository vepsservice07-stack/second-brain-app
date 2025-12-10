#!/bin/bash
# Phase 4: Polish Features
# Adds API endpoints, bulk operations, export functionality
# Usage: ./phase-4-polish.sh

echo "========================================"
echo "  Phase 4: Polish Features"
echo "========================================"
echo ""

cd second-brain-rails

echo "Creating API endpoints..."

mkdir -p app/controllers/api/v1

cat > app/controllers/api/v1/base_controller.rb << 'RUBY'
module Api
  module V1
    class BaseController < ActionController::API
      # Skip CSRF for API requests
      skip_before_action :verify_authenticity_token, raise: false
      
      # Standard JSON response
      def render_json(data, status: :ok)
        render json: data, status: status
      end
      
      def render_error(message, status: :unprocessable_entity)
        render json: { error: message }, status: status
      end
    end
  end
end
RUBY

cat > app/controllers/api/v1/notes_controller.rb << 'RUBY'
module Api
  module V1
    class NotesController < BaseController
      before_action :set_note, only: [:show, :update, :destroy]
      
      # GET /api/v1/notes
      def index
        @notes = Note.active.order(updated_at: :desc).limit(100)
        
        render_json(
          notes: @notes.map { |note| note_json(note) },
          total: @notes.count
        )
      end
      
      # GET /api/v1/notes/:id
      def show
        render_json(note: note_json(@note, include_content: true))
      end
      
      # POST /api/v1/notes
      def create
        @note = Note.new(note_params)
        
        if @note.save
          render_json(note: note_json(@note, include_content: true), status: :created)
        else
          render_error(@note.errors.full_messages.join(', '))
        end
      end
      
      # PATCH /api/v1/notes/:id
      def update
        if @note.update(note_params)
          render_json(note: note_json(@note, include_content: true))
        else
          render_error(@note.errors.full_messages.join(', '))
        end
      end
      
      # DELETE /api/v1/notes/:id
      def destroy
        @note.soft_delete
        render_json(message: 'Note deleted', note_id: @note.id)
      end
      
      # GET /api/v1/notes/search?q=query
      def search
        query = params[:q]
        
        if query.present?
          @notes = Note.active.search_by_content(query).limit(50)
          render_json(
            notes: @notes.map { |note| note_json(note) },
            query: query,
            total: @notes.count
          )
        else
          render_error('Query parameter required', status: :bad_request)
        end
      end
      
      private
      
      def set_note
        @note = Note.active.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render_error('Note not found', status: :not_found)
      end
      
      def note_params
        params.require(:note).permit(:title, :content, tag_ids: [])
      end
      
      def note_json(note, include_content: false)
        json = {
          id: note.id,
          title: note.title,
          sequence_number: note.sequence_number,
          tag_ids: note.tag_ids,
          wiki_links: note.wiki_links,
          created_at: note.created_at.iso8601,
          updated_at: note.updated_at.iso8601
        }
        
        json[:content] = note.content if include_content
        json
      end
    end
  end
end
RUBY

echo "✅ API controllers created"
echo ""

echo "Adding API routes..."

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  root "home#index"
  
  get "search", to: "search#index"
  
  resources :notes do
    member do
      post :restore
    end
    
    resources :attachments, only: [:create, :destroy]
  end
  
  resources :tags, only: [:index, :create, :destroy]
  
  # API endpoints
  namespace :api do
    namespace :v1 do
      resources :notes do
        collection do
          get :search
        end
      end
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
RUBY

echo "✅ API routes added"
echo ""

echo "Creating bulk operations..."

cat > app/controllers/bulk_operations_controller.rb << 'RUBY'
class BulkOperationsController < ApplicationController
  # POST /bulk/tag
  def tag
    note_ids = params[:note_ids] || []
    tag_ids = params[:tag_ids] || []
    
    if note_ids.empty? || tag_ids.empty?
      redirect_back fallback_location: notes_path, alert: 'Select notes and tags'
      return
    end
    
    Note.where(id: note_ids).find_each do |note|
      tag_ids.each do |tag_id|
        note.tags << Tag.find(tag_id) unless note.tag_ids.include?(tag_id.to_i)
      end
    end
    
    redirect_back fallback_location: notes_path, notice: "Tagged #{note_ids.count} notes"
  end
  
  # POST /bulk/delete
  def delete
    note_ids = params[:note_ids] || []
    
    if note_ids.empty?
      redirect_back fallback_location: notes_path, alert: 'Select notes to delete'
      return
    end
    
    Note.where(id: note_ids).find_each(&:soft_delete)
    
    redirect_back fallback_location: notes_path, notice: "Deleted #{note_ids.count} notes"
  end
  
  # POST /bulk/export
  def export
    note_ids = params[:note_ids] || []
    format = params[:format] || 'json'
    
    notes = note_ids.empty? ? Note.active.all : Note.active.where(id: note_ids)
    
    case format
    when 'json'
      send_data notes.to_json(include: [:tags, :attachments]), 
        filename: "notes-export-#{Time.current.to_i}.json",
        type: 'application/json'
    when 'markdown'
      markdown = notes.map { |note| note_to_markdown(note) }.join("\n\n---\n\n")
      send_data markdown,
        filename: "notes-export-#{Time.current.to_i}.md",
        type: 'text/markdown'
    else
      redirect_back fallback_location: notes_path, alert: 'Invalid format'
    end
  end
  
  private
  
  def note_to_markdown(note)
    md = "# #{note.title}\n\n"
    md += "seq: #{note.sequence_number || 'pending'}\n"
    md += "updated: #{note.updated_at.iso8601}\n"
    md += "tags: #{note.tags.map(&:name).join(', ')}\n" if note.tags.any?
    md += "\n---\n\n"
    md += note.content
    md
  end
end
RUBY

echo "✅ Bulk operations controller created"
echo ""

echo "Adding bulk operation routes..."

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  root "home#index"
  
  get "search", to: "search#index"
  
  resources :notes do
    member do
      post :restore
    end
    
    resources :attachments, only: [:create, :destroy]
  end
  
  resources :tags, only: [:index, :create, :destroy]
  
  # Bulk operations
  post "bulk/tag", to: "bulk_operations#tag"
  post "bulk/delete", to: "bulk_operations#delete"
  post "bulk/export", to: "bulk_operations#export"
  
  # API endpoints
  namespace :api do
    namespace :v1 do
      resources :notes do
        collection do
          get :search
        end
      end
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
RUBY

echo "✅ Bulk routes added"
echo ""

echo "Creating export functionality..."

cat > app/controllers/exports_controller.rb << 'RUBY'
class ExportsController < ApplicationController
  # GET /export/all
  def all
    format = params[:format] || 'json'
    
    case format
    when 'json'
      export_json
    when 'markdown'
      export_markdown
    else
      redirect_to root_path, alert: 'Invalid format'
    end
  end
  
  private
  
  def export_json
    data = {
      exported_at: Time.current.iso8601,
      notes: Note.active.includes(:tags, :attachments).map { |note| note_json(note) },
      tags: Tag.all.map { |tag| tag_json(tag) }
    }
    
    send_data JSON.pretty_generate(data),
      filename: "second-brain-export-#{Time.current.to_i}.json",
      type: 'application/json'
  end
  
  def export_markdown
    markdown = "# SECOND BRAIN EXPORT\n\n"
    markdown += "exported: #{Time.current.iso8601}\n"
    markdown += "notes: #{Note.active.count}\n\n"
    markdown += "---\n\n"
    
    Note.active.order(updated_at: :desc).each do |note|
      markdown += "# #{note.title}\n\n"
      markdown += "seq: #{note.sequence_number || 'pending'}\n"
      markdown += "updated: #{note.updated_at.iso8601}\n"
      markdown += "tags: #{note.tags.map(&:name).join(', ')}\n" if note.tags.any?
      markdown += "\n"
      markdown += note.content
      markdown += "\n\n---\n\n"
    end
    
    send_data markdown,
      filename: "second-brain-export-#{Time.current.to_i}.md",
      type: 'text/markdown'
  end
  
  def note_json(note)
    {
      id: note.id,
      title: note.title,
      content: note.content,
      sequence_number: note.sequence_number,
      tags: note.tags.map { |t| { id: t.id, name: t.name, color: t.color } },
      wiki_links: note.wiki_links,
      created_at: note.created_at.iso8601,
      updated_at: note.updated_at.iso8601
    }
  end
  
  def tag_json(tag)
    {
      id: tag.id,
      name: tag.name,
      color: tag.color,
      note_count: tag.notes.active.count
    }
  end
end
RUBY

echo "✅ Export controller created"
echo ""

echo "Adding export routes..."

cat > config/routes.rb << 'RUBY'
Rails.application.routes.draw do
  root "home#index"
  
  get "search", to: "search#index"
  
  resources :notes do
    member do
      post :restore
    end
    
    resources :attachments, only: [:create, :destroy]
  end
  
  resources :tags, only: [:index, :create, :destroy]
  
  # Export
  get "export/all", to: "exports#all"
  
  # Bulk operations
  post "bulk/tag", to: "bulk_operations#tag"
  post "bulk/delete", to: "bulk_operations#delete"
  post "bulk/export", to: "bulk_operations#export"
  
  # API endpoints
  namespace :api do
    namespace :v1 do
      resources :notes do
        collection do
          get :search
        end
      end
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
RUBY

echo "✅ Export routes added"
echo ""

echo "Adding export links to navigation..."

# Update layout to include export link
cat > app/views/layouts/application.html.erb << 'ERB'
<!DOCTYPE html>
<html>
  <head>
    <title>second-brain</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="turbo-cache-control" content="no-cache">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "custom", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
    <nav style="height: 48px; display: flex; align-items: center;">
      <div style="max-width: 1200px; margin: 0 auto; width: 100%; padding: 0 24px; display: flex; justify-content: space-between; align-items: center;">
        <div style="display: flex; align-items: center; gap: 32px;">
          <%= link_to root_path, style: "font-family: var(--mono); font-size: 14px; font-weight: 600; color: var(--accent-bright);" do %>
            <span style="margin-right: 8px;">🧠</span>second-brain
          <% end %>
          <div style="display: flex; gap: 24px;">
            <%= link_to "notes", notes_path, style: "font-size: 12px; color: var(--text-secondary);" %>
            <%= link_to "tags", tags_path, style: "font-size: 12px; color: var(--text-secondary);" %>
            <%= link_to "search", search_path, style: "font-size: 12px; color: var(--text-secondary);" %>
            <%= link_to "export", export_all_path(format: 'json'), style: "font-size: 12px; color: var(--text-secondary);" %>
          </div>
        </div>
        <div style="display: flex; align-items: center; gap: 12px;">
          <span class="kbd">⌘P</span>
          <span class="kbd">⌘K</span>
          <%= link_to "+ new", new_note_path, class: "btn-primary", style: "padding: 6px 12px;" %>
        </div>
      </div>
    </nav>

    <main style="max-width: 1200px; margin: 0 auto; padding: 24px;">
      <% if notice %>
        <div class="toast toast-success" style="position: relative; margin-bottom: 16px;">
          <%= notice %>
        </div>
      <% end %>
      
      <% if alert %>
        <div class="toast toast-error" style="position: relative; margin-bottom: 16px;">
          <%= alert %>
        </div>
      <% end %>

      <%= yield %>
    </main>

    <%= render 'shared/keyboard_shortcuts' %>

    <script>
      document.addEventListener('keydown', (e) => {
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;
        
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
          e.preventDefault();
          window.location.href = '<%= new_note_path %>';
        }
        
        if ((e.metaKey || e.ctrlKey) && e.key === 'p') {
          e.preventDefault();
          window.location.href = '<%= search_path %>';
        }
        
        if ((e.metaKey || e.ctrlKey) && e.key === '/') {
          e.preventDefault();
          window.location.href = '<%= notes_path %>';
        }
        
        if (e.key === '?') {
          e.preventDefault();
          const panel = document.getElementById('shortcuts-panel');
          panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
        }
        
        if (e.key === 'Escape') {
          document.getElementById('shortcuts-panel').style.display = 'none';
        }
      });
    </script>
  </body>
</html>
ERB

echo "✅ Navigation updated"
echo ""

echo "Creating API documentation..."

cat > API.md << 'MD'
# Second Brain API Documentation

Base URL: `/api/v1`

## Authentication

Currently no authentication required. Will be added in future version.

## Endpoints

### List Notes

```
GET /api/v1/notes
```

Returns up to 100 most recent notes.

**Response:**
```json
{
  "notes": [
    {
      "id": 1,
      "title": "Note Title",
      "sequence_number": 12345,
      "tag_ids": [1, 2],
      "wiki_links": ["Other Note"],
      "created_at": "2024-12-09T12:00:00Z",
      "updated_at": "2024-12-09T13:00:00Z"
    }
  ],
  "total": 42
}
```

### Get Note

```
GET /api/v1/notes/:id
```

**Response:**
```json
{
  "note": {
    "id": 1,
    "title": "Note Title",
    "content": "Note content...",
    "sequence_number": 12345,
    "tag_ids": [1, 2],
    "wiki_links": [],
    "created_at": "2024-12-09T12:00:00Z",
    "updated_at": "2024-12-09T13:00:00Z"
  }
}
```

### Create Note

```
POST /api/v1/notes
Content-Type: application/json

{
  "note": {
    "title": "New Note",
    "content": "Content here",
    "tag_ids": [1, 2]
  }
}
```

### Update Note

```
PATCH /api/v1/notes/:id
Content-Type: application/json

{
  "note": {
    "title": "Updated Title",
    "content": "Updated content"
  }
}
```

### Delete Note

```
DELETE /api/v1/notes/:id
```

Performs soft delete.

### Search Notes

```
GET /api/v1/notes/search?q=query
```

**Response:**
```json
{
  "notes": [...],
  "query": "search term",
  "total": 5
}
```

## Export

### Export All Data

```
GET /export/all?format=json
GET /export/all?format=markdown
```

Downloads complete export of all notes and tags.
MD

echo "✅ API documentation created"
echo ""

echo "========================================"
echo "  Phase 4 Complete!"
echo "========================================"
echo ""
echo "What was added:"
echo "  🔌 REST API (/api/v1/notes)"
echo "  📦 Bulk operations (tag, delete)"
echo "  💾 Export (JSON, Markdown)"
echo "  📖 API documentation (API.md)"
echo ""
echo "API Examples:"
echo "  curl http://localhost:3000/api/v1/notes"
echo "  curl http://localhost:3000/api/v1/notes/1"
echo "  curl http://localhost:3000/api/v1/notes/search?q=test"
echo ""
echo "Export:"
echo "  http://localhost:3000/export/all?format=json"
echo "  http://localhost:3000/export/all?format=markdown"
echo ""
echo "Restart dev services to activate new features!"
echo ""