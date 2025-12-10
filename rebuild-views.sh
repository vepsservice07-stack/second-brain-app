#!/bin/bash
# Second Brain - Views That Match Your Voice
# Precision. Ledgers. Evidence. No performance.
# Usage: ./rebuild-views.sh

echo "========================================"
echo "  Rebuilding Views"
echo "========================================"
echo ""

cd second-brain-rails

echo "Creating home view - the ledger overview..."

cat > app/views/home/index.html.erb << 'ERB'
<div style="max-width: 1000px;">
  <div style="margin-bottom: 32px;">
    <div style="font-size: 24px; font-weight: 700; letter-spacing: 0.1em;">SECOND BRAIN</div>
    <div class="meta" style="margin-top: 4px;">STATUS :: ACTIVE :: <%= Time.current.strftime("%Y-%m-%d %H:%M:%S") %></div>
  </div>

  <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 32px;">
    <div class="card" style="padding: 20px;">
      <div class="stat-value"><%= @note_count %></div>
      <div class="meta" style="margin-top: 4px;">NOTES</div>
    </div>
    
    <div class="card" style="padding: 20px;">
      <div class="stat-value"><%= @tag_count %></div>
      <div class="meta" style="margin-top: 4px;">TAGS</div>
    </div>
    
    <div class="card" style="padding: 20px;">
      <div style="font-size: 14px; color: var(--accent);">
        <%= link_to "⌘K NEW NOTE", new_note_path %>
      </div>
      <div class="meta" style="margin-top: 4px;">KEYBOARD</div>
    </div>
  </div>

  <% if @recent_notes.any? %>
    <div style="margin-bottom: 16px;">
      <div style="display: flex; justify-content: space-between; align-items: center;">
        <div style="font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em;">RECENT</div>
        <%= link_to "VIEW ALL →", notes_path, style: "font-size: 11px;" %>
      </div>
    </div>
    
    <div>
      <% @recent_notes.each do |note| %>
        <%= link_to note, class: "note-card", style: "display: block; text-decoration: none;" do %>
          <div style="display: flex; justify-content: space-between; align-items: start;">
            <div style="flex: 1;">
              <div style="font-size: 13px; font-weight: 600;"><%= note.title %></div>
              <div class="meta" style="margin-top: 4px;">
                seq: <span class="sequence sequence-<%= note.sequence_number ? 'confirmed' : 'pending' %>"><%= note.sequence_number || 'pending' %></span>
                · <%= time_ago_in_words(note.updated_at) %>
                <% if note.tags.any? %>
                  · <%= note.tags.count %> tags
                <% end %>
              </div>
            </div>
          </div>
        <% end %>
      <% end %>
    </div>
  <% else %>
    <div class="card" style="padding: 40px; text-align: center;">
      <div class="meta">EMPTY STATE</div>
      <div style="margin-top: 8px;">
        <%= link_to "+ CREATE FIRST NOTE", new_note_path, style: "font-size: 12px;" %>
      </div>
    </div>
  <% end %>
</div>
ERB

echo "✅ Home view created"
echo ""

echo "Creating notes index - the master ledger..."

cat > app/views/notes/index.html.erb << 'ERB'
<div style="max-width: 1000px;">
  <div style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center;">
    <div>
      <div style="font-size: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em;">NOTES</div>
      <div class="meta" style="margin-top: 4px;"><%= @notes.total_count %> TOTAL</div>
    </div>
    <%= link_to "+ NEW", new_note_path, class: "btn-primary" %>
  </div>

  <% if @notes.any? %>
    <div style="margin-bottom: 8px;">
      <div style="display: grid; grid-template-columns: 1fr 120px 100px; padding: 8px 12px; border-bottom: 1px solid var(--bg-tertiary); font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; color: var(--text-tertiary);">
        <div>TITLE</div>
        <div>SEQUENCE</div>
        <div>UPDATED</div>
      </div>
    </div>
    
    <div>
      <% @notes.each do |note| %>
        <%= link_to note, class: "note-card", style: "display: block; text-decoration: none;" do %>
          <div style="display: grid; grid-template-columns: 1fr 120px 100px; align-items: center;">
            <div>
              <div style="font-size: 13px; font-weight: 600;"><%= note.title %></div>
              <% if note.tags.any? %>
                <div style="margin-top: 4px; display: flex; gap: 4px;">
                  <% note.tags.first(3).each do |tag| %>
                    <span class="tag-pill" style="background: <%= tag.color %>20; color: <%= tag.color %>; border-color: <%= tag.color %>;">
                      <%= tag.name %>
                    </span>
                  <% end %>
                </div>
              <% end %>
            </div>
            <div class="meta">
              <span class="sequence sequence-<%= note.sequence_number ? 'confirmed' : 'pending' %>">
                <%= note.sequence_number || 'pending' %>
              </span>
            </div>
            <div class="meta"><%= time_ago_in_words(note.updated_at) %></div>
          </div>
        <% end %>
      <% end %>
    </div>
    
    <div style="margin-top: 24px;">
      <%= paginate @notes %>
    </div>
  <% else %>
    <div class="card" style="padding: 40px; text-align: center;">
      <div class="meta">NO NOTES</div>
      <div style="margin-top: 8px;">
        <%= link_to "+ CREATE FIRST NOTE", new_note_path, style: "font-size: 12px;" %>
      </div>
    </div>
  <% end %>
</div>
ERB

echo "✅ Notes index created"
echo ""

echo "Creating note show - the witness document..."

cat > app/views/notes/show.html.erb << 'ERB'
<div style="max-width: 900px;">
  <div style="margin-bottom: 16px;">
    <%= link_to "← NOTES", notes_path, style: "font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em;" %>
  </div>

  <div class="card" style="padding: 32px;">
    <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 24px;">
      <div style="flex: 1;">
        <div style="font-size: 20px; font-weight: 700; margin-bottom: 8px;"><%= @note.title %></div>
        <div class="meta">
          seq: <span class="sequence sequence-<%= @note.sequence_number ? 'confirmed' : 'pending' %>"><%= @note.sequence_number || 'pending' %></span>
          · updated <%= time_ago_in_words(@note.updated_at) %>
          <% if @note.wiki_links.any? %>
            · <%= @note.wiki_links.count %> links
          <% end %>
          <% if @note.incoming_links.any? %>
            · <%= @note.incoming_links.count %> backlinks
          <% end %>
        </div>
      </div>
      <div style="display: flex; gap: 8px;">
        <%= link_to "EDIT", edit_note_path(@note), class: "btn", style: "font-size: 10px;" %>
        <%= button_to "DELETE", note_path(@note), method: :delete, data: { confirm: "Delete this note?" }, class: "btn", style: "font-size: 10px; color: var(--margin-color); border-color: var(--margin-color);" %>
      </div>
    </div>
    
    <% if @tags.any? %>
      <div style="display: flex; gap: 6px; margin-bottom: 24px; padding-bottom: 24px; border-bottom: 1px solid var(--bg-tertiary);">
        <% @tags.each do |tag| %>
          <span class="tag-pill" style="background: <%= tag.color %>20; color: <%= tag.color %>; border-color: <%= tag.color %>;">
            <%= tag.name %>
          </span>
        <% end %>
      </div>
    <% end %>
    
    <div class="note-content">
      <%= @note.content_html %>
    </div>
  </div>
  
  <% if @note.linked_notes.any? %>
    <div class="card" style="padding: 20px; margin-top: 16px;">
      <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 12px;">LINKED NOTES</div>
      <div style="display: flex; flex-direction: column; gap: 6px;">
        <% @note.linked_notes.each do |linked_note| %>
          <%= link_to linked_note, style: "font-size: 12px; text-decoration: none;" do %>
            → <%= linked_note.title %>
          <% end %>
        <% end %>
      </div>
    </div>
  <% end %>
  
  <% if @note.incoming_links.any? %>
    <div class="card" style="padding: 20px; margin-top: 16px;">
      <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 12px;">BACKLINKS</div>
      <div style="display: flex; flex-direction: column; gap: 6px;">
        <% @note.incoming_links.each do |link| %>
          <%= link_to link.source_note, style: "font-size: 12px; text-decoration: none;" do %>
            ← <%= link.source_note.title %>
          <% end %>
        <% end %>
      </div>
    </div>
  <% end %>
</div>
ERB

echo "✅ Note show created"
echo ""

echo "Creating note form - the input interface..."

cat > app/views/notes/_form.html.erb << 'ERB'
<div class="card" style="padding: 24px;">
  <%= form_with(model: note, local: true) do |form| %>
    <% if note.errors.any? %>
      <div style="margin-bottom: 20px; padding: 12px; background: rgba(255, 74, 74, 0.1); border-left: 2px solid var(--margin-color);">
        <div style="font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 8px;">
          ERRORS (<%= note.errors.count %>)
        </div>
        <ul style="margin: 0; padding-left: 20px; font-size: 12px;">
          <% note.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div style="margin-bottom: 20px;">
      <%= form.label :title, style: "display: block; font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 6px; color: var(--text-secondary);" %>
      <%= form.text_field :title, style: "width: 100%; font-size: 14px; font-weight: 600;" %>
    </div>

    <div style="margin-bottom: 20px;">
      <%= form.label :content, style: "display: block; font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 6px; color: var(--text-secondary);" %>
      <%= form.text_area :content, rows: 20, style: "width: 100%; font-size: 13px; line-height: 1.8; resize: vertical;" %>
    </div>

    <% if Tag.any? %>
      <div style="margin-bottom: 20px;">
        <label style="display: block; font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 8px; color: var(--text-secondary);">TAGS</label>
        <div style="display: flex; flex-wrap: wrap; gap: 8px;">
          <% Tag.all.each do |tag| %>
            <label style="display: flex; align-items: center; gap: 6px; cursor: pointer; padding: 6px 10px; background: var(--bg-tertiary); border: 1px solid var(--bg-tertiary);">
              <%= check_box_tag "tag_ids[]", tag.id, note.tag_ids.include?(tag.id), style: "margin: 0;" %>
              <span style="font-size: 11px; color: <%= tag.color %>; text-transform: uppercase; letter-spacing: 0.05em;">
                <%= tag.name %>
              </span>
            </label>
          <% end %>
        </div>
      </div>
    <% end %>

    <div style="display: flex; gap: 8px;">
      <%= form.submit note.new_record? ? "CREATE NOTE" : "UPDATE NOTE", class: "btn-primary" %>
      <%= link_to "CANCEL", note.new_record? ? root_path : note_path(note), class: "btn" %>
    </div>
  <% end %>
</div>

<div class="card" style="padding: 16px; margin-top: 16px;">
  <div style="font-size: 10px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 8px; color: var(--text-secondary);">SYNTAX GUIDE</div>
  <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; font-size: 11px;">
    <div>
      <div class="meta" style="margin-bottom: 4px;">DELIMITERS</div>
      <div>:: atomic separator</div>
      <div>[[note title]] wiki link</div>
    </div>
    <div>
      <div class="meta" style="margin-bottom: 4px;">PATTERNS</div>
      <div>(0.1) margin/unaccounted</div>
      <div>seq: 12345 sequence number</div>
    </div>
    <div>
      <div class="meta" style="margin-bottom: 4px;">HEADERS</div>
      <div>SECTION X: title</div>
      <div>UNMEASURED.XXX call number</div>
    </div>
    <div>
      <div class="meta" style="margin-bottom: 4px;">MARKDOWN</div>
      <div># heading</div>
      <div>```code blocks```</div>
    </div>
  </div>
</div>
ERB

echo "✅ Form created"
echo ""

cat > app/views/notes/new.html.erb << 'ERB'
<div style="max-width: 900px;">
  <div style="margin-bottom: 16px;">
    <%= link_to "← NOTES", notes_path, style: "font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em;" %>
  </div>
  
  <div style="margin-bottom: 24px;">
    <div style="font-size: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em;">NEW NOTE</div>
  </div>

  <%= render "form", note: @note %>
</div>
ERB

cat > app/views/notes/edit.html.erb << 'ERB'
<div style="max-width: 900px;">
  <div style="margin-bottom: 16px;">
    <%= link_to "← BACK", note_path(@note), style: "font-size: 11px; text-transform: uppercase; letter-spacing: 0.1em;" %>
  </div>
  
  <div style="margin-bottom: 24px;">
    <div style="font-size: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em;">EDIT NOTE</div>
    <div class="meta" style="margin-top: 4px;">seq: <%= @note.sequence_number || 'pending' %></div>
  </div>

  <%= render "form", note: @note %>
</div>
ERB

echo "✅ New/edit views created"
echo ""

echo "Creating search view - the query interface..."

cat > app/views/search/index.html.erb << 'ERB'
<div style="max-width: 1000px;">
  <div style="margin-bottom: 24px;">
    <div style="font-size: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em;">SEARCH</div>
  </div>

  <%= form_with url: search_path, method: :get, style: "margin-bottom: 24px;" do |f| %>
    <%= f.text_field :q, 
      value: @query,
      placeholder: "QUERY...",
      autofocus: true,
      style: "width: 100%; padding: 16px; font-size: 14px; text-transform: uppercase; letter-spacing: 0.05em;" %>
  <% end %>

  <% if @query.present? %>
    <div class="meta" style="margin-bottom: 16px;">
      RESULTS: <%= @results.count %>
    </div>

    <% if @results.any? %>
      <div>
        <% @results.each do |note| %>
          <%= link_to note, class: "note-card", style: "display: block; text-decoration: none;" do %>
            <div style="display: flex; justify-content: space-between; align-items: start;">
              <div style="flex: 1;">
                <div style="font-size: 13px; font-weight: 600;"><%= note.title %></div>
                <div class="meta" style="margin-top: 4px;">
                  seq: <%= note.sequence_number || 'pending' %>
                  · <%= time_ago_in_words(note.updated_at) %>
                </div>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    <% else %>
      <div class="card" style="padding: 40px; text-align: center;">
        <div class="meta">NO RESULTS</div>
      </div>
    <% end %>
  <% else %>
    <div class="card" style="padding: 40px; text-align: center;">
      <div class="meta">ENTER QUERY</div>
    </div>
  <% end %>
</div>
ERB

echo "✅ Search view created"
echo ""

echo "Creating tags view - the taxonomy..."

cat > app/views/tags/index.html.erb << 'ERB'
<div style="max-width: 900px;">
  <div style="margin-bottom: 24px;">
    <div style="font-size: 18px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.1em;">TAGS</div>
    <div class="meta" style="margin-top: 4px;"><%= Tag.count %> TOTAL</div>
  </div>

  <div class="card" style="padding: 20px; margin-bottom: 24px;">
    <%= form_with model: Tag.new, local: true, style: "display: flex; gap: 8px; align-items: end;" do |form| %>
      <div style="flex: 1;">
        <%= form.label :name, style: "display: block; font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 6px; color: var(--text-secondary);" %>
        <%= form.text_field :name, placeholder: "TAG NAME", style: "width: 100%;" %>
      </div>
      <div>
        <%= form.label :color, style: "display: block; font-size: 10px; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 6px; color: var(--text-secondary);" %>
        <%= form.color_field :color, value: "#4a9eff", style: "width: 80px; height: 36px; padding: 2px; cursor: pointer;" %>
      </div>
      <%= form.submit "CREATE", class: "btn-primary", style: "margin-top: 19px;" %>
    <% end %>
  </div>

  <% if Tag.any? %>
    <div style="display: grid; gap: 8px;">
      <% Tag.all.each do |tag| %>
        <div class="card" style="padding: 16px; display: flex; justify-content: space-between; align-items: center;">
          <div>
            <span class="tag-pill" style="background: <%= tag.color %>20; color: <%= tag.color %>; border-color: <%= tag.color %>; font-size: 12px;">
              <%= tag.name %>
            </span>
            <span class="meta" style="margin-left: 12px;"><%= tag.notes.count %> notes</span>
          </div>
          <%= button_to "DELETE", tag_path(tag), method: :delete, data: { confirm: "Delete this tag?" }, class: "btn", style: "font-size: 10px; color: var(--margin-color); border-color: var(--margin-color);" %>
        </div>
      <% end %>
    </div>
  <% else %>
    <div class="card" style="padding: 40px; text-align: center;">
      <div class="meta">NO TAGS</div>
    </div>
  <% end %>
</div>
ERB

echo "✅ Tags view created"
echo ""

echo "========================================"
echo "  Views Rebuilt Complete!"
echo "========================================"
echo ""
echo "All views now match your aesthetic:"
echo "  - Ledger-style layouts"
echo "  - Terminal precision"
echo "  - UPPERCASE headers"
echo "  - Sequence numbers prominent"
echo "  - No performance, just documentation"
echo "  - Grid layouts where appropriate"
echo "  - Meta information always visible"
echo ""
echo "This is a tool for witnessing."
echo "Not for celebrating."
echo ""