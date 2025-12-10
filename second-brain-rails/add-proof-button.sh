#!/bin/bash
set -e

echo "======================================"
echo "🔒 Adding Priority Proof Button"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Update the note show view with the lock button
cat > app/views/notes/show.html.erb << 'HTML'
<div class="container">
  <div class="card" style="margin-bottom: 1rem;">
    <div class="flex-between mb-3" style="flex-wrap: wrap; gap: 1rem;">
      <h1 style="margin: 0;"><%= @note.title %></h1>
      <div class="flex gap-2" style="flex-wrap: wrap;">
        <%= link_to new_note_priority_proof_path(@note), class: "btn btn-accent" do %>
          🔒 Generate Proof
        <% end %>
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
    
    <div class="flex gap-3 text-subtle" style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid rgba(91, 124, 153, 0.1); font-size: 0.9rem; flex-wrap: wrap;">
      <span>📝 <%= @note.content.to_s.split.length %> words</span>
      <span>•</span>
      <span>🕐 Created <%= time_ago_in_words(@note.created_at) %> ago</span>
      <span>•</span>
      <span>Updated <%= time_ago_in_words(@note.updated_at) %> ago</span>
    </div>
  </div>
  
  <% if @note.priority_proofs.any? %>
    <div class="card">
      <h3 class="mb-2">🔒 Priority Proofs (<%= @note.priority_proofs.count %>)</h3>
      <p class="text-subtle mb-3" style="font-size: 0.9rem;">
        Cryptographic certificates proving when you created this note
      </p>
      <div style="display: grid; gap: 0.75rem;">
        <% @note.priority_proofs.order(created_at: :desc).each do |proof| %>
          <%= link_to note_priority_proof_path(@note, proof), style: "text-decoration: none;" do %>
            <div style="padding: 1rem; background: var(--color-bg); border-radius: 6px; border: 1px solid var(--color-border); transition: all 0.3s var(--ease-smooth);">
              <div class="flex-between" style="flex-wrap: wrap; gap: 0.5rem;">
                <div>
                  <div style="font-family: monospace; font-size: 0.85rem; color: var(--color-primary);">
                    <%= proof.certificate_hash[0..15] %>...
                  </div>
                  <div class="text-subtle" style="font-size: 0.8rem; margin-top: 0.25rem;">
                    Sequence #<%= proof.sequence_number %>
                  </div>
                </div>
                <div class="text-subtle" style="font-size: 0.85rem;">
                  Generated <%= time_ago_in_words(proof.created_at) %> ago
                </div>
              </div>
            </div>
          <% end %>
        <% end %>
      </div>
    </div>
  <% end %>
  
  <div class="mt-2">
    <%= link_to notes_path, class: "btn btn-ghost" do %>
      ← Back to Notes
    <% end %>
  </div>
</div>
HTML

echo "✓ Note show view updated with priority proof button"

echo ""
echo "======================================"
echo "✅ Priority Proof Button Added!"
echo "======================================"
echo ""
echo "You should now see:"
echo "  🔒 Generate Proof button (gold accent button)"
echo "  📝 Edit button (grey)"
echo "  🗑️  Delete button (red text)"
echo ""
echo "The buttons are in the top right of each note."
echo ""
echo "Refresh your browser and open any note!"
echo ""