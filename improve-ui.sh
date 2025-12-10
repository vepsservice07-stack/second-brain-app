#!/bin/bash
# Second Brain - UI/UX Improvements
# Makes the interface cleaner, more technical, and keyboard-friendly
# Usage: ./improve-ui.sh

echo "========================================"
echo "  UI/UX Improvements"
echo "========================================"
echo ""

cd second-brain-rails

echo "Creating improved stylesheet..."

# Add custom styles
cat > app/assets/stylesheets/custom.css << 'CSS'
/* Technical, clean theme */
:root {
  --primary: #4F46E5;
  --primary-dark: #4338CA;
  --text: #1F2937;
  --text-light: #6B7280;
  --bg: #F9FAFB;
  --border: #E5E7EB;
  --mono: 'SF Mono', 'Monaco', 'Inconsolata', 'Fira Code', 'Dank Mono', monospace;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', sans-serif;
  background: var(--bg);
  color: var(--text);
}

/* Monospace for note content */
.note-content,
textarea[id*="content"],
.prose {
  font-family: var(--mono);
  font-size: 14px;
  line-height: 1.6;
}

/* Focus states */
input:focus,
textarea:focus,
select:focus {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}

/* Keyboard hint badges */
.kbd {
  display: inline-block;
  padding: 2px 6px;
  font-family: var(--mono);
  font-size: 11px;
  background: #F3F4F6;
  border: 1px solid var(--border);
  border-radius: 3px;
  color: var(--text-light);
}

/* Compact, technical cards */
.note-card {
  border-left: 3px solid var(--primary);
  transition: all 0.15s ease;
}

.note-card:hover {
  border-left-color: var(--primary-dark);
  background: white;
}

/* Monospace metadata */
.meta {
  font-family: var(--mono);
  font-size: 12px;
  color: var(--text-light);
}

/* Cleaner buttons */
.btn-primary {
  background: var(--primary);
  transition: background 0.15s ease;
}

.btn-primary:hover {
  background: var(--primary-dark);
}

/* Tag pills - more compact */
.tag-pill {
  padding: 2px 8px;
  font-size: 11px;
  font-weight: 500;
  border-radius: 4px;
  font-family: var(--mono);
}

/* Hide scrollbars but keep functionality */
.hide-scrollbar {
  scrollbar-width: thin;
  scrollbar-color: var(--border) transparent;
}

.hide-scrollbar::-webkit-scrollbar {
  width: 4px;
  height: 4px;
}

.hide-scrollbar::-webkit-scrollbar-track {
  background: transparent;
}

.hide-scrollbar::-webkit-scrollbar-thumb {
  background: var(--border);
  border-radius: 2px;
}

/* Status indicators */
.status-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  margin-right: 6px;
}

.status-active { background: #10B981; }
.status-draft { background: #F59E0B; }
.status-archived { background: #6B7280; }
CSS

echo "✅ Custom styles created"
echo ""

echo "Updating layout with keyboard shortcuts..."

# Update application layout
cat > app/views/layouts/application.html.erb << 'ERB'
<!DOCTYPE html>
<html>
  <head>
    <title>Second Brain</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="turbo-cache-control" content="no-cache">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "tailwind", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "custom", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="bg-gray-50">
    <nav class="bg-white border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-14">
          <div class="flex items-center space-x-8">
            <%= link_to root_path, class: "font-mono text-lg font-semibold text-indigo-600" do %>
              🧠 second-brain
            <% end %>
            <div class="hidden sm:flex sm:space-x-6">
              <%= link_to "notes", notes_path, class: "text-sm text-gray-600 hover:text-gray-900" %>
              <%= link_to "tags", tags_path, class: "text-sm text-gray-600 hover:text-gray-900" %>
            </div>
          </div>
          <div class="flex items-center space-x-3">
            <span class="kbd hidden sm:inline">⌘K</span>
            <%= link_to "+ new", new_note_path, class: "px-3 py-1.5 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded" %>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
      <% if notice %>
        <div class="mb-4 px-4 py-2 bg-green-50 border-l-3 border-green-500 text-sm text-green-800">
          <%= notice %>
        </div>
      <% end %>
      
      <% if alert %>
        <div class="mb-4 px-4 py-2 bg-red-50 border-l-3 border-red-500 text-sm text-red-800">
          <%= alert %>
        </div>
      <% end %>

      <%= yield %>
    </main>

    <script>
      // Keyboard shortcuts
      document.addEventListener('keydown', (e) => {
        // Cmd/Ctrl + K for new note
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
          e.preventDefault();
          window.location.href = '<%= new_note_path %>';
        }
        // Cmd/Ctrl + / for notes list
        if ((e.metaKey || e.ctrlKey) && e.key === '/') {
          e.preventDefault();
          window.location.href = '<%= notes_path %>';
        }
      });
    </script>
  </body>
</html>
ERB

echo "✅ Layout updated with keyboard shortcuts"
echo ""

echo "Updating notes index for cleaner look..."

cat > app/views/notes/index.html.erb << 'ERB'
<div class="max-w-5xl">
  <div class="flex items-center justify-between mb-6">
    <div>
      <h1 class="text-2xl font-semibold text-gray-900">Notes</h1>
      <p class="meta mt-1"><%= @notes.total_count %> total</p>
    </div>
  </div>

  <% if @notes.any? %>
    <div class="space-y-2">
      <% @notes.each do |note| %>
        <%= link_to note, class: "block note-card bg-white px-4 py-3 hover:shadow-sm" do %>
          <div class="flex items-start justify-between">
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2">
                <span class="status-dot status-active"></span>
                <h3 class="text-sm font-medium text-gray-900 truncate"><%= note.title %></h3>
              </div>
              <p class="meta mt-1 truncate"><%= note.content.truncate(120) %></p>
              <div class="flex items-center gap-3 mt-2">
                <% if note.tags.any? %>
                  <div class="flex gap-1">
                    <% note.tags.first(3).each do |tag| %>
                      <span class="tag-pill" style="background: <%= tag.color %>20; color: <%= tag.color %>">
                        <%= tag.name %>
                      </span>
                    <% end %>
                    <% if note.tags.count > 3 %>
                      <span class="tag-pill bg-gray-100 text-gray-600">+<%= note.tags.count - 3 %></span>
                    <% end %>
                  </div>
                <% end %>
                <span class="meta"><%= time_ago_in_words(note.updated_at) %></span>
              </div>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
    
    <div class="mt-6">
      <%= paginate @notes %>
    </div>
  <% else %>
    <div class="text-center py-12 bg-white rounded">
      <p class="text-gray-500 mb-4">No notes yet</p>
      <%= link_to "+ Create first note", new_note_path, class: "text-sm text-indigo-600 hover:text-indigo-700" %>
    </div>
  <% end %>
</div>
ERB

echo "✅ Notes index improved"
echo ""

echo "Updating note show page..."

cat > app/views/notes/show.html.erb << 'ERB'
<div class="max-w-4xl">
  <div class="mb-4">
    <%= link_to "← notes", notes_path, class: "text-sm text-indigo-600 hover:text-indigo-700" %>
  </div>

  <div class="bg-white shadow-sm rounded-lg">
    <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-start">
      <div>
        <h1 class="text-xl font-semibold text-gray-900"><%= @note.title %></h1>
        <p class="meta mt-1">
          seq: <%= @note.sequence_number || 'pending' %> · 
          updated <%= time_ago_in_words(@note.updated_at) %> ago
        </p>
      </div>
      <div class="flex gap-2">
        <%= link_to "edit", edit_note_path(@note), class: "px-3 py-1.5 text-sm border border-gray-300 hover:bg-gray-50 rounded" %>
        <%= button_to "delete", note_path(@note), method: :delete, data: { confirm: "Delete?" }, class: "px-3 py-1.5 text-sm text-red-600 hover:bg-red-50 rounded" %>
      </div>
    </div>
    
    <div class="px-6 py-4">
      <% if @tags.any? %>
        <div class="mb-4 flex gap-2">
          <% @tags.each do |tag| %>
            <span class="tag-pill" style="background: <%= tag.color %>20; color: <%= tag.color %>">
              <%= tag.name %>
            </span>
          <% end %>
        </div>
      <% end %>
      
      <div class="note-content whitespace-pre-wrap"><%= @note.content %></div>
    </div>
  </div>
</div>
ERB

echo "✅ Note show page improved"
echo ""

echo "Updating home page..."

cat > app/views/home/index.html.erb << 'ERB'
<div class="max-w-5xl">
  <div class="mb-8">
    <h1 class="text-3xl font-semibold text-gray-900">second brain</h1>
    <p class="meta mt-2">capture → organize → retrieve</p>
  </div>

  <div class="grid grid-cols-3 gap-4 mb-8">
    <div class="bg-white px-6 py-4">
      <div class="text-3xl font-semibold text-gray-900"><%= @note_count %></div>
      <div class="meta mt-1">notes</div>
    </div>
    
    <div class="bg-white px-6 py-4">
      <div class="text-3xl font-semibold text-gray-900"><%= @tag_count %></div>
      <div class="meta mt-1">tags</div>
    </div>
    
    <div class="bg-white px-6 py-4">
      <div class="text-sm text-indigo-600 hover:text-indigo-700">
        <%= link_to "+ new note", new_note_path %>
      </div>
      <div class="meta mt-1">⌘K</div>
    </div>
  </div>

  <% if @recent_notes.any? %>
    <div class="bg-white shadow-sm rounded">
      <div class="px-6 py-3 border-b border-gray-200 flex justify-between items-center">
        <h2 class="text-sm font-medium text-gray-900">recent</h2>
        <%= link_to "view all →", notes_path, class: "text-sm text-indigo-600 hover:text-indigo-700" %>
      </div>
      <div class="divide-y divide-gray-200">
        <% @recent_notes.each do |note| %>
          <%= link_to note, class: "block px-6 py-3 hover:bg-gray-50" do %>
            <div class="flex justify-between items-start">
              <div>
                <p class="text-sm font-medium text-gray-900"><%= note.title %></p>
                <p class="meta mt-1 line-clamp-1"><%= note.content.truncate(100) %></p>
              </div>
              <span class="meta ml-4"><%= time_ago_in_words(note.updated_at) %></span>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
  <% else %>
    <div class="text-center py-12 bg-white rounded">
      <p class="text-gray-500 mb-4">empty brain 🤔</p>
      <%= link_to "+ create first note", new_note_path, class: "text-sm text-indigo-600 hover:text-indigo-700" %>
    </div>
  <% end %>
</div>
ERB

echo "✅ Home page improved"
echo ""

echo "========================================"
echo "  UI/UX Improvements Complete!"
echo "========================================"
echo ""
echo "Changes made:"
echo "  ✨ Monospace font for all note content"
echo "  ⌨️  Keyboard shortcuts (⌘K = new note, ⌘/ = notes list)"
echo "  🎨 Cleaner, more technical aesthetic"
echo "  📊 Sequence numbers visible"
echo "  🏷️  Compact tag display"
echo "  ⚡ Faster visual feedback"
echo ""
echo "Refresh your browser to see changes!"
echo ""