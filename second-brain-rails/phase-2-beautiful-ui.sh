#!/bin/bash
set -e

echo "======================================"
echo "🎨 Phase 2: The Therapist Aesthetic"
echo "======================================"
echo ""
echo "Transforming Second Brain into a beautiful,"
echo "warm, calm space for thinking..."
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Step 1: Create the beautiful application layout
echo "Step 1: Creating beautiful layout..."
echo "======================================"

cat > app/views/layouts/application.html.erb << 'HTML'
<!DOCTYPE html>
<html>
  <head>
    <title>Second Brain · Think Clearly</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="turbo-visit-control" content="reload">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    
    <style>
      /* ============================================ */
      /* THE THERAPIST AESTHETIC - DESIGN SYSTEM */
      /* ============================================ */
      
      :root {
        /* Primary: Warm, calming blue-grey */
        --color-primary: #5B7C99;
        --color-primary-light: #7B9CB9;
        --color-primary-dark: #3B5C79;
        
        /* Accent: Soft gold for important moments */
        --color-accent: #D4A574;
        --color-accent-light: #E8C9A1;
        
        /* Neutrals: Warm greys */
        --color-bg: #F8F7F5;
        --color-bg-elevated: #FFFFFF;
        --color-text: #2C3E50;
        --color-text-subtle: #7F8C99;
        
        /* States */
        --color-success: #6B9080;
        --color-warning: #D4A574;
        --color-error: #C17767;
        
        /* Shadows: Soft and subtle */
        --shadow-sm: 0 2px 8px rgba(91, 124, 153, 0.08);
        --shadow-md: 0 4px 16px rgba(91, 124, 153, 0.12);
        --shadow-lg: 0 8px 32px rgba(91, 124, 153, 0.16);
        
        /* Transitions */
        --ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);
      }
      
      /* ============================================ */
      /* RESET & BASE */
      /* ============================================ */
      
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 16px;
        line-height: 1.6;
        color: var(--color-text);
        background: var(--color-bg);
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }
      
      h1, h2, h3, h4, h5, h6 {
        font-family: 'Crimson Pro', Georgia, serif;
        font-weight: 600;
        color: var(--color-text);
        line-height: 1.2;
      }
      
      h1 { font-size: 2.5rem; margin-bottom: 1rem; }
      h2 { font-size: 2rem; margin-bottom: 0.875rem; }
      h3 { font-size: 1.5rem; margin-bottom: 0.75rem; }
      
      /* ============================================ */
      /* NAVBAR - Calm, spacious, minimal */
      /* ============================================ */
      
      .navbar {
        background: var(--color-bg-elevated);
        border-bottom: 1px solid rgba(91, 124, 153, 0.1);
        padding: 1.5rem 2rem;
        position: sticky;
        top: 0;
        z-index: 100;
        backdrop-filter: blur(10px);
        transition: all 0.3s var(--ease-smooth);
      }
      
      .navbar-container {
        max-width: 1400px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .navbar-brand {
        font-family: 'Crimson Pro', Georgia, serif;
        font-size: 1.5rem;
        font-weight: 600;
        color: var(--color-primary);
        text-decoration: none;
        letter-spacing: -0.02em;
        transition: color 0.3s var(--ease-smooth);
      }
      
      .navbar-brand:hover {
        color: var(--color-primary-dark);
      }
      
      .navbar-links {
        display: flex;
        gap: 2rem;
        align-items: center;
      }
      
      .navbar-links a {
        color: var(--color-text-subtle);
        text-decoration: none;
        font-size: 0.9rem;
        font-weight: 500;
        transition: color 0.3s var(--ease-smooth);
        position: relative;
      }
      
      .navbar-links a:hover {
        color: var(--color-primary);
      }
      
      .navbar-links a::after {
        content: '';
        position: absolute;
        bottom: -4px;
        left: 0;
        width: 0;
        height: 2px;
        background: var(--color-accent);
        transition: width 0.3s var(--ease-smooth);
      }
      
      .navbar-links a:hover::after {
        width: 100%;
      }
      
      /* ============================================ */
      /* NOTICES & ALERTS - Gentle, non-intrusive */
      /* ============================================ */
      
      .notice, .alert {
        padding: 1rem 2rem;
        margin: 0;
        font-size: 0.95rem;
        animation: slideDown 0.4s var(--ease-smooth);
      }
      
      @keyframes slideDown {
        from {
          opacity: 0;
          transform: translateY(-10px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      
      .notice {
        background: rgba(107, 144, 128, 0.1);
        color: var(--color-success);
        border-left: 3px solid var(--color-success);
      }
      
      .alert {
        background: rgba(193, 119, 103, 0.1);
        color: var(--color-error);
        border-left: 3px solid var(--color-error);
      }
      
      /* ============================================ */
      /* CONTAINER - Breathing room */
      /* ============================================ */
      
      .container {
        max-width: 900px;
        margin: 0 auto;
        padding: 3rem 2rem;
      }
      
      .container-wide {
        max-width: 1200px;
        margin: 0 auto;
        padding: 3rem 2rem;
      }
      
      /* ============================================ */
      /* CARDS - Soft, elevated, warm */
      /* ============================================ */
      
      .card {
        background: var(--color-bg-elevated);
        border-radius: 12px;
        padding: 2rem;
        box-shadow: var(--shadow-sm);
        transition: all 0.3s var(--ease-smooth);
      }
      
      .card:hover {
        box-shadow: var(--shadow-md);
        transform: translateY(-2px);
      }
      
      .card-title {
        margin-bottom: 0.5rem;
        color: var(--color-text);
      }
      
      .card-subtitle {
        color: var(--color-text-subtle);
        font-size: 0.9rem;
        margin-bottom: 1rem;
      }
      
      /* ============================================ */
      /* BUTTONS - Warm, inviting, gentle */
      /* ============================================ */
      
      .btn {
        display: inline-block;
        padding: 0.75rem 1.5rem;
        border-radius: 8px;
        text-decoration: none;
        font-weight: 500;
        font-size: 0.95rem;
        transition: all 0.3s var(--ease-smooth);
        cursor: pointer;
        border: none;
      }
      
      .btn-primary {
        background: var(--color-primary);
        color: white;
      }
      
      .btn-primary:hover {
        background: var(--color-primary-dark);
        transform: translateY(-1px);
        box-shadow: var(--shadow-md);
      }
      
      .btn-accent {
        background: var(--color-accent);
        color: white;
      }
      
      .btn-accent:hover {
        background: #C89564;
        transform: translateY(-1px);
        box-shadow: var(--shadow-md);
      }
      
      .btn-secondary {
        background: rgba(91, 124, 153, 0.1);
        color: var(--color-primary);
      }
      
      .btn-secondary:hover {
        background: rgba(91, 124, 153, 0.2);
      }
      
      .btn-ghost {
        background: transparent;
        color: var(--color-text-subtle);
        border: 1px solid rgba(91, 124, 153, 0.2);
      }
      
      .btn-ghost:hover {
        background: var(--color-bg);
        border-color: var(--color-primary);
        color: var(--color-primary);
      }
      
      /* ============================================ */
      /* FORMS - Clean, spacious, approachable */
      /* ============================================ */
      
      .form-group {
        margin-bottom: 1.5rem;
      }
      
      .form-label {
        display: block;
        margin-bottom: 0.5rem;
        font-weight: 500;
        color: var(--color-text);
        font-size: 0.95rem;
      }
      
      .form-input {
        width: 100%;
        padding: 0.875rem 1rem;
        border: 2px solid rgba(91, 124, 153, 0.15);
        border-radius: 8px;
        font-size: 1rem;
        font-family: inherit;
        color: var(--color-text);
        background: var(--color-bg-elevated);
        transition: all 0.3s var(--ease-smooth);
      }
      
      .form-input:focus {
        outline: none;
        border-color: var(--color-primary);
        box-shadow: 0 0 0 3px rgba(91, 124, 153, 0.1);
      }
      
      .form-textarea {
        min-height: 200px;
        resize: vertical;
      }
      
      /* ============================================ */
      /* UTILITIES */
      /* ============================================ */
      
      .text-subtle {
        color: var(--color-text-subtle);
        font-size: 0.9rem;
      }
      
      .text-center {
        text-align: center;
      }
      
      .mb-1 { margin-bottom: 0.5rem; }
      .mb-2 { margin-bottom: 1rem; }
      .mb-3 { margin-bottom: 1.5rem; }
      .mb-4 { margin-bottom: 2rem; }
      
      .mt-1 { margin-top: 0.5rem; }
      .mt-2 { margin-top: 1rem; }
      .mt-3 { margin-top: 1.5rem; }
      .mt-4 { margin-top: 2rem; }
      
      .flex {
        display: flex;
      }
      
      .flex-between {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      
      .flex-center {
        display: flex;
        justify-content: center;
        align-items: center;
      }
      
      .gap-1 { gap: 0.5rem; }
      .gap-2 { gap: 1rem; }
      .gap-3 { gap: 1.5rem; }
      
      /* ============================================ */
      /* MOBILE RESPONSIVE */
      /* ============================================ */
      
      @media (max-width: 768px) {
        .navbar {
          padding: 1rem;
        }
        
        .navbar-links {
          gap: 1rem;
        }
        
        .navbar-links a {
          font-size: 0.85rem;
        }
        
        .container, .container-wide {
          padding: 2rem 1rem;
        }
        
        h1 { font-size: 2rem; }
        h2 { font-size: 1.5rem; }
        h3 { font-size: 1.25rem; }
        
        .card {
          padding: 1.5rem;
        }
      }
    </style>
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:wght@400;600&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  </head>

  <body>
    <nav class="navbar">
      <div class="navbar-container">
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
            <%= link_to "Sign Up", new_user_registration_path, class: "btn btn-primary", style: "padding: 0.5rem 1rem;" %>
          <% end %>
        </div>
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

echo "✓ Beautiful layout created"

# Step 2: Update notes index with beautiful design
echo ""
echo "Step 2: Creating beautiful notes index..."
echo "======================================"

cat > app/views/notes/index.html.erb << 'HTML'
<div class="container">
  <div class="flex-between mb-4">
    <div>
      <h1>Your Notes</h1>
      <p class="text-subtle">Capture your thoughts, organize your mind</p>
    </div>
    <%= link_to new_note_path, class: "btn btn-primary" do %>
      <span>✨ New Note</span>
    <% end %>
  </div>

  <% if @notes.any? %>
    <div style="display: grid; gap: 1.5rem;">
      <% @notes.each do |note| %>
        <%= link_to note, style: "text-decoration: none;" do %>
          <div class="card">
            <h3 class="card-title"><%= note.title %></h3>
            <p class="card-subtitle">
              <%= truncate(note.content, length: 200) %>
            </p>
            <div class="flex gap-2 text-subtle" style="font-size: 0.85rem;">
              <span>📝 <%= note.content.to_s.split.length %> words</span>
              <span>•</span>
              <span>🕐 <%= time_ago_in_words(note.updated_at) %> ago</span>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
  <% else %>
    <div class="card text-center" style="padding: 4rem 2rem;">
      <h2 style="color: var(--color-text-subtle); margin-bottom: 1rem;">
        ✨ No notes yet
      </h2>
      <p class="text-subtle mb-3">
        Start capturing your thoughts and watch your second brain come to life
      </p>
      <%= link_to "Create Your First Note", new_note_path, class: "btn btn-accent" %>
    </div>
  <% end %>
</div>
HTML

echo "✓ Beautiful notes index created"

# Step 3: Update note show page
echo ""
echo "Step 3: Creating beautiful note view..."
echo "======================================"

cat > app/views/notes/show.html.erb << 'HTML'
<div class="container">
  <div class="card" style="margin-bottom: 1rem;">
    <div class="flex-between mb-3">
      <h1 style="margin: 0;"><%= @note.title %></h1>
      <div class="flex gap-2">
        <%= link_to "Edit", edit_note_path(@note), class: "btn btn-secondary" %>
        <%= button_to "Delete", @note, method: :delete, 
            data: { turbo_confirm: "Are you sure?" }, 
            class: "btn btn-ghost",
            style: "color: var(--color-error);" %>
      </div>
    </div>
    
    <div style="line-height: 1.8; color: var(--color-text); white-space: pre-wrap; font-size: 1.05rem;">
      <%= @note.content %>
    </div>
    
    <div class="flex gap-3 text-subtle" style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid rgba(91, 124, 153, 0.1); font-size: 0.9rem;">
      <span>📝 <%= @note.content.to_s.split.length %> words</span>
      <span>•</span>
      <span>Created <%= time_ago_in_words(@note.created_at) %> ago</span>
      <span>•</span>
      <span>Updated <%= time_ago_in_words(@note.updated_at) %> ago</span>
    </div>
  </div>
  
  <div>
    <%= link_to notes_path, class: "btn btn-ghost" do %>
      ← Back to Notes
    <% end %>
  </div>
</div>
HTML

echo "✓ Beautiful note view created"

# Step 4: Update form
echo ""
echo "Step 4: Creating beautiful form..."
echo "======================================"

cat > app/views/notes/_form.html.erb << 'HTML'
<%= form_with(model: note) do |form| %>
  <% if note.errors.any? %>
    <div class="card" style="background: rgba(193, 119, 103, 0.1); border-left: 3px solid var(--color-error); margin-bottom: 2rem;">
      <h3 style="color: var(--color-error); margin-bottom: 1rem;">
        <%= pluralize(note.errors.count, "error") %> prohibited this note from being saved:
      </h3>
      <ul style="margin-left: 1.5rem; color: var(--color-error);">
        <% note.errors.each do |error| %>
          <li><%= error.full_message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div class="form-group">
    <%= form.label :title, "Title", class: "form-label" %>
    <%= form.text_field :title, class: "form-input", placeholder: "What's on your mind?" %>
  </div>

  <div class="form-group">
    <%= form.label :content, "Content", class: "form-label" %>
    <%= form.text_area :content, rows: 15, class: "form-input form-textarea", placeholder: "Start writing... we're capturing your thinking patterns." %>
  </div>

  <div class="flex gap-2">
    <%= form.submit "Save Note", class: "btn btn-primary" %>
    <%= link_to "Cancel", notes_path, class: "btn btn-secondary" %>
  </div>
<% end %>
HTML

echo "✓ Beautiful form created"

cat > app/views/notes/new.html.erb << 'HTML'
<div class="container">
  <div class="mb-4">
    <h1>New Note</h1>
    <p class="text-subtle">Capture your thoughts</p>
  </div>
  
  <div class="card">
    <%= render "form", note: @note %>
  </div>
</div>
HTML

cat > app/views/notes/edit.html.erb << 'HTML'
<div class="container">
  <div class="mb-4">
    <h1>Edit Note</h1>
    <p class="text-subtle">Refine your thoughts</p>
  </div>
  
  <div class="card">
    <%= render "form", note: @note %>
  </div>
</div>
HTML

echo "✓ Form views created"

# Step 5: Update profile page
echo ""
echo "Step 5: Creating beautiful profile..."
echo "======================================"

cat > app/views/profiles/show.html.erb << 'HTML'
<div class="container-wide">
  <div class="mb-4">
    <h1>Your Cognitive Profile</h1>
    <p class="text-subtle">Understanding how you think</p>
  </div>
  
  <!-- Stats Grid -->
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin-bottom: 3rem;">
    <div class="card text-center">
      <h2 style="color: var(--color-primary); margin-bottom: 0.5rem;">
        <%= @analytics[:total_notes] %>
      </h2>
      <p class="text-subtle">Notes Created</p>
    </div>
    
    <div class="card text-center">
      <h2 style="color: var(--color-accent); margin-bottom: 0.5rem;">
        <%= number_to_human(@total_words) %>
      </h2>
      <p class="text-subtle">Words Written</p>
    </div>
    
    <div class="card text-center">
      <h2 style="color: var(--color-success); margin-bottom: 0.5rem;">
        <%= @analytics[:avg_velocity] || 'N/A' %>
      </h2>
      <p class="text-subtle">Avg Velocity</p>
    </div>
    
    <div class="card text-center">
      <h2 style="color: var(--color-primary-light); margin-bottom: 0.5rem;">
        <%= @analytics[:avg_confidence] || 'N/A' %>%
      </h2>
      <p class="text-subtle">Avg Confidence</p>
    </div>
  </div>
  
  <!-- Recent Notes -->
  <div class="card">
    <h2 class="mb-3">Recent Notes</h2>
    
    <% if @recent_notes.any? %>
      <div style="display: grid; gap: 1rem;">
        <% @recent_notes.each do |note| %>
          <%= link_to note, style: "text-decoration: none; display: block; padding: 1.5rem; background: var(--color-bg); border-radius: 8px; transition: all 0.3s var(--ease-smooth);" do %>
            <h3 style="color: var(--color-text); margin-bottom: 0.5rem;"><%= note.title %></h3>
            <p style="color: var(--color-text-subtle); margin-bottom: 0.5rem;"><%= truncate(note.content, length: 150) %></p>
            <span class="text-subtle" style="font-size: 0.85rem;">
              <%= time_ago_in_words(note.updated_at) %> ago
            </span>
          <% end %>
        <% end %>
      </div>
    <% else %>
      <p class="text-subtle text-center" style="padding: 2rem;">
        No notes yet. <%= link_to "Create your first note", new_note_path, style: "color: var(--color-primary);" %>!
      </p>
    <% end %>
  </div>
  
  <div class="mt-4">
    <%= link_to notes_path, class: "btn btn-ghost" do %>
      ← Back to Notes
    <% end %>
  </div>
</div>
HTML

echo "✓ Beautiful profile created"

echo ""
echo "======================================"
echo "✅ Phase 2 Complete!"
echo "======================================"
echo ""
echo "Your Second Brain is now BEAUTIFUL! 🎨"
echo ""
echo "What changed:"
echo "  ✓ Warm, calming color palette"
echo "  ✓ Elegant typography (Crimson Pro + Inter)"
echo "  ✓ Smooth, organic animations"
echo "  ✓ Soft shadows and rounded corners"
echo "  ✓ Mobile-responsive design"
echo "  ✓ Therapist-like calm aesthetic"
echo ""
echo "Refresh your browser to see the magic!"
echo ""
echo "Next: Phase 3 - 20 Structure Types 🏗️"
echo ""