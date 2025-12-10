#!/bin/bash
set -e

echo "======================================"
echo "🔧 Fixing Application Layout"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Create a simple, clean application layout
cat > app/views/layouts/application.html.erb << 'HTML'
<!DOCTYPE html>
<html>
  <head>
    <title>Second Brain</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="turbo-visit-control" content="reload">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      
      body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        background: #f8f9fa;
        color: #333;
      }
      
      .navbar {
        background: white;
        border-bottom: 1px solid #e0e0e0;
        padding: 1rem 2rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .navbar-brand {
        font-size: 1.5rem;
        font-weight: 600;
        color: #333;
        text-decoration: none;
      }
      
      .navbar-links {
        display: flex;
        gap: 1.5rem;
        align-items: center;
      }
      
      .navbar-links a {
        color: #666;
        text-decoration: none;
        font-size: 0.9rem;
      }
      
      .navbar-links a:hover {
        color: #333;
      }
      
      .notice, .alert {
        padding: 1rem 2rem;
        margin: 0;
      }
      
      .notice {
        background: #d4edda;
        color: #155724;
      }
      
      .alert {
        background: #f8d7da;
        color: #721c24;
      }
      
      .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 2rem;
      }
    </style>
  </head>

  <body>
    <nav class="navbar">
      <div>
        <%= link_to "Second Brain", root_path, class: "navbar-brand" %>
      </div>
      
      <div class="navbar-links">
        <% if user_signed_in? %>
          <%= link_to "Notes", notes_path %>
          <%= link_to "Profile", profile_path %>
          <%= link_to "Sign Out", destroy_user_session_path, data: { turbo_method: :delete } %>
        <% else %>
          <%= link_to "Sign In", new_user_session_path %>
          <%= link_to "Sign Up", new_user_registration_path %>
        <% end %>
      </div>
    </nav>
    
    <% if notice %>
      <div class="notice"><%= notice %></div>
    <% end %>
    
    <% if alert %>
      <div class="alert"><%= alert %></div>
    <% end %>

    <%= yield %>
  </body>
</html>
HTML

echo "✓ Updated application layout"

# Also create a simple notes index view if it doesn't exist
mkdir -p app/views/notes

cat > app/views/notes/index.html.erb << 'HTML'
<div class="container">
  <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
    <h1>Your Notes</h1>
    <%= link_to "New Note", new_note_path, style: "padding: 0.75rem 1.5rem; background: #007bff; color: white; text-decoration: none; border-radius: 4px;" %>
  </div>

  <% if @notes.any? %>
    <div style="display: grid; gap: 1rem;">
      <% @notes.each do |note| %>
        <div style="background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
          <h2 style="margin-bottom: 0.5rem;">
            <%= link_to note.title, note, style: "color: #333; text-decoration: none;" %>
          </h2>
          <p style="color: #666; margin-bottom: 0.5rem;">
            <%= truncate(note.content, length: 200) %>
          </p>
          <div style="display: flex; gap: 1rem; font-size: 0.9rem; color: #999;">
            <span>Updated <%= time_ago_in_words(note.updated_at) %> ago</span>
          </div>
        </div>
      <% end %>
    </div>
  <% else %>
    <div style="text-align: center; padding: 4rem; background: white; border-radius: 8px;">
      <h2 style="color: #666; margin-bottom: 1rem;">No notes yet</h2>
      <p style="color: #999; margin-bottom: 2rem;">Start capturing your thoughts</p>
      <%= link_to "Create Your First Note", new_note_path, style: "padding: 0.75rem 1.5rem; background: #007bff; color: white; text-decoration: none; border-radius: 4px; display: inline-block;" %>
    </div>
  <% end %>
</div>
HTML

echo "✓ Created notes index view"

# Create show view
cat > app/views/notes/show.html.erb << 'HTML'
<div class="container">
  <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 2rem;">
      <h1><%= @note.title %></h1>
      <div style="display: flex; gap: 0.5rem;">
        <%= link_to "Edit", edit_note_path(@note), style: "padding: 0.5rem 1rem; background: #6c757d; color: white; text-decoration: none; border-radius: 4px;" %>
        <%= button_to "Delete", @note, method: :delete, data: { turbo_confirm: "Are you sure?" }, style: "padding: 0.5rem 1rem; background: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer;" %>
      </div>
    </div>
    
    <div style="line-height: 1.6; color: #333; white-space: pre-wrap;">
      <%= @note.content %>
    </div>
    
    <div style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #e0e0e0; color: #999; font-size: 0.9rem;">
      <p>Created <%= time_ago_in_words(@note.created_at) %> ago</p>
      <p>Updated <%= time_ago_in_words(@note.updated_at) %> ago</p>
    </div>
  </div>
  
  <div style="margin-top: 1rem;">
    <%= link_to "← Back to Notes", notes_path, style: "color: #666; text-decoration: none;" %>
  </div>
</div>
HTML

echo "✓ Created notes show view"

# Create new/edit form view
cat > app/views/notes/_form.html.erb << 'HTML'
<%= form_with(model: note, style: "display: flex; flex-direction: column; gap: 1.5rem;") do |form| %>
  <% if note.errors.any? %>
    <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 4px;">
      <h3><%= pluralize(note.errors.count, "error") %> prohibited this note from being saved:</h3>
      <ul style="margin: 0.5rem 0 0 1.5rem;">
        <% note.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :title, style: "display: block; margin-bottom: 0.5rem; font-weight: 500;" %>
    <%= form.text_field :title, style: "width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem;" %>
  </div>

  <div>
    <%= form.label :content, style: "display: block; margin-bottom: 0.5rem; font-weight: 500;" %>
    <%= form.text_area :content, rows: 15, style: "width: 100%; padding: 0.75rem; border: 1px solid #ddd; border-radius: 4px; font-size: 1rem; font-family: inherit;" %>
  </div>

  <div style="display: flex; gap: 0.5rem;">
    <%= form.submit "Save Note", style: "padding: 0.75rem 1.5rem; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem;" %>
    <%= link_to "Cancel", notes_path, style: "padding: 0.75rem 1.5rem; background: #6c757d; color: white; text-decoration: none; border-radius: 4px; display: inline-block;" %>
  </div>
<% end %>
HTML

echo "✓ Created form partial"

cat > app/views/notes/new.html.erb << 'HTML'
<div class="container">
  <h1 style="margin-bottom: 2rem;">New Note</h1>
  
  <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <%= render "form", note: @note %>
  </div>
</div>
HTML

echo "✓ Created new note view"

cat > app/views/notes/edit.html.erb << 'HTML'
<div class="container">
  <h1 style="margin-bottom: 2rem;">Edit Note</h1>
  
  <div style="background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
    <%= render "form", note: @note %>
  </div>
</div>
HTML

echo "✓ Created edit note view"

echo ""
echo "======================================"
echo "✅ Layout Fixed!"
echo "======================================"
echo ""
echo "Refresh your browser and you should see:"
echo "  ✓ Clean navbar"
echo "  ✓ Sign In / Sign Up links"
echo "  ✓ Working navigation"
echo ""
echo "Sign in with:"
echo "  Email: test@example.com"
echo "  Password: password123"
echo ""