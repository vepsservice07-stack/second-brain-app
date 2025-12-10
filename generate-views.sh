#!/bin/bash
# Second Brain - Generate Views
# Creates the UI views with Tailwind CSS styling
# Usage: ./generate-views.sh

echo "========================================"
echo "  Generating Views"
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

echo "Creating layout..."

# Update application layout with Tailwind
cat > app/views/layouts/application.html.erb << 'EOF'
<!DOCTYPE html>
<html>
  <head>
    <title>Second Brain</title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="turbo-cache-control" content="no-cache">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "tailwind", "inter-font", "data-turbo-track": "reload" %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body class="bg-gray-50">
    <nav class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <%= link_to root_path, class: "text-xl font-bold text-indigo-600" do %>
                🧠 Second Brain
              <% end %>
            </div>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <%= link_to "Notes", notes_path, class: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium" %>
              <%= link_to "Tags", tags_path, class: "border-transparent text-gray-500 hover:border-gray-300 hover:text-gray-700 inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium" %>
            </div>
          </div>
          <div class="flex items-center">
            <%= link_to new_note_path, class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" do %>
              ➕ New Note
            <% end %>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <% if notice %>
        <div class="mb-4 rounded-md bg-green-50 p-4">
          <div class="flex">
            <div class="ml-3">
              <p class="text-sm font-medium text-green-800"><%= notice %></p>
            </div>
          </div>
        </div>
      <% end %>
      
      <% if alert %>
        <div class="mb-4 rounded-md bg-red-50 p-4">
          <div class="flex">
            <div class="ml-3">
              <p class="text-sm font-medium text-red-800"><%= alert %></p>
            </div>
          </div>
        </div>
      <% end %>

      <%= yield %>
    </main>
  </body>
</html>
EOF

echo "✅ Layout created"
echo ""

echo "Creating Home views..."

# Home index
cat > app/views/home/index.html.erb << 'EOF'
<div class="px-4 sm:px-0">
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-900">Welcome to Your Second Brain</h1>
    <p class="mt-2 text-gray-600">Capture your thoughts, organize your knowledge.</p>
  </div>

  <!-- Stats -->
  <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3 mb-8">
    <div class="bg-white overflow-hidden shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <dt class="text-sm font-medium text-gray-500 truncate">Total Notes</dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900"><%= @note_count %></dd>
      </div>
    </div>
    
    <div class="bg-white overflow-hidden shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <dt class="text-sm font-medium text-gray-500 truncate">Tags</dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900"><%= @tag_count %></dd>
      </div>
    </div>
    
    <div class="bg-white overflow-hidden shadow rounded-lg">
      <div class="px-4 py-5 sm:p-6">
        <dt class="text-sm font-medium text-gray-500 truncate">Quick Actions</dt>
        <dd class="mt-2">
          <%= link_to "New Note", new_note_path, class: "text-indigo-600 hover:text-indigo-900 text-sm font-medium" %>
        </dd>
      </div>
    </div>
  </div>

  <!-- Recent Notes -->
  <div class="bg-white shadow overflow-hidden sm:rounded-lg">
    <div class="px-4 py-5 sm:px-6 flex justify-between items-center">
      <h2 class="text-lg leading-6 font-medium text-gray-900">Recent Notes</h2>
      <%= link_to "View All", notes_path, class: "text-indigo-600 hover:text-indigo-900 text-sm font-medium" %>
    </div>
    <div class="border-t border-gray-200">
      <% if @recent_notes.any? %>
        <ul role="list" class="divide-y divide-gray-200">
          <% @recent_notes.each do |note| %>
            <li>
              <%= link_to note, class: "block hover:bg-gray-50" do %>
                <div class="px-4 py-4 sm:px-6">
                  <div class="flex items-center justify-between">
                    <p class="text-sm font-medium text-indigo-600 truncate"><%= note.title %></p>
                    <div class="ml-2 flex-shrink-0 flex">
                      <p class="text-xs text-gray-500"><%= time_ago_in_words(note.updated_at) %> ago</p>
                    </div>
                  </div>
                  <div class="mt-2">
                    <p class="text-sm text-gray-600 line-clamp-2"><%= note.content.truncate(150) %></p>
                  </div>
                </div>
              <% end %>
            </li>
          <% end %>
        </ul>
      <% else %>
        <div class="px-4 py-12 text-center">
          <p class="text-gray-500">No notes yet. Create your first note to get started!</p>
          <%= link_to "Create Note", new_note_path, class: "mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700" %>
        </div>
      <% end %>
    </div>
  </div>
</div>
EOF

echo "✅ Home views created"
echo ""

echo "Creating Notes views..."

# Notes index
cat > app/views/notes/index.html.erb << 'EOF'
<div class="px-4 sm:px-0">
  <div class="sm:flex sm:items-center mb-6">
    <div class="sm:flex-auto">
      <h1 class="text-2xl font-semibold text-gray-900">Notes</h1>
      <p class="mt-2 text-sm text-gray-700">All your notes in one place</p>
    </div>
    <div class="mt-4 sm:mt-0 sm:ml-16 sm:flex-none">
      <%= link_to new_note_path, class: "inline-flex items-center justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2 sm:w-auto" do %>
        Add note
      <% end %>
    </div>
  </div>

  <div class="bg-white shadow overflow-hidden sm:rounded-md">
    <% if @notes.any? %>
      <ul role="list" class="divide-y divide-gray-200">
        <% @notes.each do |note| %>
          <li>
            <%= link_to note, class: "block hover:bg-gray-50" do %>
              <div class="px-4 py-4 sm:px-6">
                <div class="flex items-center justify-between">
                  <p class="text-sm font-medium text-indigo-600 truncate"><%= note.title %></p>
                  <div class="ml-2 flex-shrink-0 flex">
                    <p class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                      <%= time_ago_in_words(note.updated_at) %> ago
                    </p>
                  </div>
                </div>
                <div class="mt-2 sm:flex sm:justify-between">
                  <div class="sm:flex">
                    <p class="text-sm text-gray-500 line-clamp-2"><%= note.content.truncate(200) %></p>
                  </div>
                </div>
                <% if note.tags.any? %>
                  <div class="mt-2 flex flex-wrap gap-2">
                    <% note.tags.each do |tag| %>
                      <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium" style="background-color: <%= tag.color %>20; color: <%= tag.color %>">
                        <%= tag.name %>
                      </span>
                    <% end %>
                  </div>
                <% end %>
              </div>
            <% end %>
          </li>
        <% end %>
      </ul>
      
      <div class="px-4 py-3 border-t border-gray-200">
        <%= paginate @notes %>
      </div>
    <% else %>
      <div class="text-center py-12">
        <h3 class="mt-2 text-sm font-medium text-gray-900">No notes</h3>
        <p class="mt-1 text-sm text-gray-500">Get started by creating a new note.</p>
        <div class="mt-6">
          <%= link_to new_note_path, class: "inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" do %>
            Add note
          <% end %>
        </div>
      </div>
    <% end %>
  </div>
</div>
EOF

# Notes show
cat > app/views/notes/show.html.erb << 'EOF'
<div class="px-4 sm:px-0">
  <div class="mb-6">
    <%= link_to "← Back to notes", notes_path, class: "text-sm text-indigo-600 hover:text-indigo-900" %>
  </div>

  <div class="bg-white shadow overflow-hidden sm:rounded-lg">
    <div class="px-4 py-5 sm:px-6 flex justify-between items-start">
      <div>
        <h1 class="text-2xl font-bold text-gray-900"><%= @note.title %></h1>
        <p class="mt-1 text-sm text-gray-500">
          Last updated <%= time_ago_in_words(@note.updated_at) %> ago
        </p>
      </div>
      <div class="flex space-x-2">
        <%= link_to "Edit", edit_note_path(@note), class: "inline-flex items-center px-3 py-2 border border-gray-300 shadow-sm text-sm leading-4 font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
        <%= button_to "Delete", note_path(@note), method: :delete, data: { confirm: "Are you sure?" }, class: "inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500" %>
      </div>
    </div>
    
    <div class="border-t border-gray-200 px-4 py-5 sm:px-6">
      <% if @tags.any? %>
        <div class="mb-4 flex flex-wrap gap-2">
          <% @tags.each do |tag| %>
            <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium" style="background-color: <%= tag.color %>20; color: <%= tag.color %>">
              <%= tag.name %>
            </span>
          <% end %>
        </div>
      <% end %>
      
      <div class="prose max-w-none">
        <%= simple_format(@note.content) %>
      </div>
    </div>
  </div>
</div>
EOF

# Notes new/edit form (shared)
cat > app/views/notes/_form.html.erb << 'EOF'
<%= form_with(model: note, class: "space-y-6") do |form| %>
  <% if note.errors.any? %>
    <div class="rounded-md bg-red-50 p-4">
      <h3 class="text-sm font-medium text-red-800">
        <%= pluralize(note.errors.count, "error") %> prohibited this note from being saved:
      </h3>
      <ul class="mt-2 text-sm text-red-700 list-disc list-inside">
        <% note.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <div>
    <%= form.label :title, class: "block text-sm font-medium text-gray-700" %>
    <%= form.text_field :title, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm", placeholder: "Enter note title" %>
  </div>

  <div>
    <%= form.label :content, class: "block text-sm font-medium text-gray-700" %>
    <%= form.text_area :content, rows: 15, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm font-mono", placeholder: "Write your note here..." %>
    <p class="mt-2 text-sm text-gray-500">Supports Markdown formatting</p>
  </div>

  <div>
    <label class="block text-sm font-medium text-gray-700">Tags</label>
    <div class="mt-2 flex flex-wrap gap-2">
      <% @all_tags.each do |tag| %>
        <label class="inline-flex items-center">
          <%= check_box_tag "tag_ids[]", tag.id, note.tags.include?(tag), class: "rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" %>
          <span class="ml-2 text-sm text-gray-700"><%= tag.name %></span>
        </label>
      <% end %>
    </div>
  </div>

  <div class="flex justify-end space-x-3">
    <%= link_to "Cancel", notes_path, class: "inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
    <%= form.submit class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
  </div>
<% end %>
EOF

# Notes new
cat > app/views/notes/new.html.erb << 'EOF'
<div class="px-4 sm:px-0">
  <div class="mb-6">
    <%= link_to "← Back", notes_path, class: "text-sm text-indigo-600 hover:text-indigo-900" %>
  </div>
  
  <div class="bg-white shadow sm:rounded-lg">
    <div class="px-4 py-5 sm:p-6">
      <h1 class="text-lg leading-6 font-medium text-gray-900 mb-6">New Note</h1>
      <%= render "form", note: @note %>
    </div>
  </div>
</div>
EOF

# Notes edit
cat > app/views/notes/edit.html.erb << 'EOF'
<div class="px-4 sm:px-0">
  <div class="mb-6">
    <%= link_to "← Back", @note, class: "text-sm text-indigo-600 hover:text-indigo-900" %>
  </div>
  
  <div class="bg-white shadow sm:rounded-lg">
    <div class="px-4 py-5 sm:p-6">
      <h1 class="text-lg leading-6 font-medium text-gray-900 mb-6">Edit Note</h1>
      <%= render "form", note: @note %>
    </div>
  </div>
</div>
EOF

echo "✅ Notes views created"
echo ""

echo "Creating Tags views..."

# Tags index
cat > app/views/tags/index.html.erb << 'EOF'
<div class="px-4 sm:px-0">
  <div class="sm:flex sm:items-center mb-6">
    <div class="sm:flex-auto">
      <h1 class="text-2xl font-semibold text-gray-900">Tags</h1>
      <p class="mt-2 text-sm text-gray-700">Organize your notes with tags</p>
    </div>
  </div>

  <!-- Create new tag -->
  <div class="bg-white shadow sm:rounded-lg mb-6">
    <div class="px-4 py-5 sm:p-6">
      <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Create New Tag</h3>
      <%= form_with(model: @tag, class: "flex gap-4 items-end") do |form| %>
        <div class="flex-1">
          <%= form.label :name, class: "block text-sm font-medium text-gray-700" %>
          <%= form.text_field :name, class: "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm", placeholder: "Tag name" %>
        </div>
        
        <div>
          <%= form.label :color, class: "block text-sm font-medium text-gray-700" %>
          <%= form.color_field :color, value: "##{SecureRandom.hex(3)}", class: "mt-1 block h-10 w-20 rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500" %>
        </div>
        
        <%= form.submit "Create Tag", class: "inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
      <% end %>
    </div>
  </div>

  <!-- Tags list -->
  <div class="bg-white shadow overflow-hidden sm:rounded-md">
    <% if @tags.any? %>
      <ul role="list" class="divide-y divide-gray-200">
        <% @tags.each do |tag| %>
          <li class="px-4 py-4 sm:px-6">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium" style="background-color: <%= tag.color %>20; color: <%= tag.color %>">
                  <%= tag.name %>
                </span>
                <span class="text-sm text-gray-500"><%= tag.notes.count %> notes</span>
              </div>
              <%= button_to "Delete", tag_path(tag), method: :delete, data: { confirm: "Delete this tag?" }, class: "text-sm text-red-600 hover:text-red-900" %>
            </div>
          </li>
        <% end %>
      </ul>
    <% else %>
      <div class="text-center py-12">
        <p class="text-gray-500">No tags yet. Create your first tag above!</p>
      </div>
    <% end %>
  </div>
</div>
EOF

echo "✅ Tags views created"
echo ""

echo "========================================"
echo "  Views Generation Complete!"
echo "========================================"
echo ""
echo "Views created:"
echo "  🏠 Home dashboard"
echo "  📝 Notes CRUD (index, show, new, edit)"
echo "  🏷️  Tags management"
echo ""
echo "Restart your Rails server to see the changes!"
echo ""