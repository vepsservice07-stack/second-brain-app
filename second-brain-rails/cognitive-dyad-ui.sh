#!/bin/bash
set -e

echo "======================================"
echo "🎨 Complete Cognitive Dyad UI"
echo "Left Brain Analytics + Right Brain Rhythm"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Complete note show page with BOTH hemispheres
cat > app/views/notes/show.html.erb << 'HTML'
<div class="note-container" id="noteContainer">
  <!-- Ambient Overlay -->
  <div id="ambientOverlay" class="ambient-overlay"></div>
  
  <!-- Two-Column Layout: Left Brain | Right Brain -->
  <div class="cognitive-split">
    
    <!-- LEFT HEMISPHERE: Analytical -->
    <div class="left-brain">
      <h2 class="brain-label">📊 Analytical View</h2>
      
      <!-- Structure Badge -->
      <div class="structure-badge" id="structureBadge">
        <span class="badge-icon"><%= @note.detect_structure[:emoji] %></span>
        <span class="badge-text"><%= @note.detect_structure[:name] %></span>
      </div>
      
      <!-- Stats Card -->
      <div class="stats-card">
        <h3>📈 Content Analysis</h3>
        
        <div class="stat-row">
          <span class="stat-label">Words</span>
          <span class="stat-value"><%= @note.word_count %></span>
        </div>
        
        <div class="stat-row">
          <span class="stat-label">Sentences</span>
          <span class="stat-value"><%= @note.sentence_count %></span>
        </div>
        
        <div class="stat-row">
          <span class="stat-label">Reading time</span>
          <span class="stat-value"><%= @note.reading_time_minutes %> min</span>
        </div>
        
        <div class="stat-row">
          <span class="stat-label">Created</span>
          <span class="stat-value"><%= @note.created_at.strftime("%b %d, %l:%M %p") %></span>
        </div>
      </div>
    </div>
    
    <!-- RIGHT HEMISPHERE: Rhythmic -->
    <div class="right-brain">
      <h2 class="brain-label">🎵 Rhythmic View</h2>
      
      <% if @rhythm_signature %>
        <!-- Rhythm Signature Card -->
        <div class="rhythm-card">
          <h3>Your Writing Rhythm</h3>
          
          <div class="rhythm-visualizer" id="rhythmViz">
            <div class="pulse-particle" id="pulseParticle"></div>
          </div>
          
          <button onclick="playRhythm()" class="btn btn-accent" id="playBtn">
            ▶️ Play Writing Rhythm
          </button>
          
          <div class="rhythm-stats">
            <div class="rhythm-stat">
              <span class="stat-icon">🎼</span>
              <div>
                <div class="stat-label">Avg Tempo</div>
                <div class="stat-value"><%= @rhythm_signature[:avg_bpm] %> BPM</div>
              </div>
            </div>
            
            <div class="rhythm-stat">
              <span class="stat-icon">⚡</span>
              <div>
                <div class="stat-label">Spark Moments</div>
                <div class="stat-value"><%= @rhythm_signature[:spark_count] %></div>
              </div>
            </div>
            
            <div class="rhythm-stat">
              <span class="stat-icon">🧘</span>
              <div>
                <div class="stat-label">Contemplation</div>
                <div class="stat-value"><%= (@rhythm_signature[:total_pauses_ms] / 1000.0).round(1) %>s</div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Spark Moments -->
        <% if @spark_moments.any? %>
          <div class="spark-moments-card">
            <h3>⚡ Breakthrough Moments</h3>
            <% @spark_moments.first(3).each do |spark| %>
              <div class="spark-moment">
                <span class="spark-icon">
                  <%= spark.event_type == 'pause' ? '🧘' : '💫' %>
                </span>
                <div class="spark-details">
                  <div class="spark-type">
                    <%= spark.event_type == 'pause' ? 'Deep Pause' : 'Breakthrough Burst' %>
                  </div>
                  <div class="spark-meta">
                    <% if spark.duration_ms %>
                      <%= (spark.duration_ms / 1000.0).round(1) %>s contemplation
                    <% elsif spark.bpm %>
                      <%= spark.bpm %> BPM surge
                    <% end %>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
        <% end %>
      <% else %>
        <div class="no-rhythm">
          <p>💭 This note doesn't have rhythm data yet.</p>
          <p class="text-subtle">Create new notes to capture your thinking rhythm!</p>
        </div>
      <% end %>
    </div>
  </div>
  
  <!-- Main Content (Full Width Below) -->
  <div class="note-header">
    <h1 class="note-title"><%= @note.title %></h1>
    <div class="note-meta">
      <span>📝 <%= pluralize(@note.word_count, 'word') %></span>
      <span>•</span>
      <span>⏱️ <%= @note.reading_time_minutes %> min read</span>
      <span>•</span>
      <span>🕐 <%= time_ago_in_words(@note.created_at) %> ago</span>
    </div>
  </div>
  
  <div class="note-content">
    <%= simple_format(@note.content) %>
  </div>
  
  <!-- Quick Actions -->
  <div class="quick-actions">
    <%= link_to edit_note_path(@note), class: "action-btn action-edit" do %>
      ✏️ Edit
    <% end %>
    
    <button onclick="copyToClipboard()" class="action-btn action-copy">
      📋 Copy
    </button>
    
    <%= link_to @note, method: :delete, data: { confirm: 'Are you sure?' }, class: "action-btn action-delete" do %>
      🗑️ Delete
    <% end %>
  </div>
  
  <div class="back-link">
    <%= link_to notes_path, class: "btn btn-ghost" do %>
      ← Back to Notes
    <% end %>
  </div>
</div>

<style>
  .note-container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem 1rem;
  }
  
  /* Ambient overlay */
  .ambient-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    pointer-events: none;
    z-index: 0;
    opacity: 0;
    transition: all 2s ease;
  }
  
  /* Cognitive Split Layout */
  .cognitive-split {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
    margin-bottom: 3rem;
  }
  
  .brain-label {
    font-size: 1.2rem;
    margin-bottom: 1.5rem;
    color: var(--color-text);
    font-weight: 600;
  }
  
  /* LEFT BRAIN STYLES */
  .left-brain {
    padding: 2rem;
    background: linear-gradient(135deg, rgba(91, 124, 153, 0.05) 0%, transparent 100%);
    border-radius: 12px;
    border-left: 3px solid var(--color-primary);
  }
  
  .structure-badge {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    padding: 0.5rem 1rem;
    background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-light) 100%);
    color: white;
    border-radius: 20px;
    font-size: 0.85rem;
    font-weight: 500;
    margin-bottom: 1.5rem;
  }
  
  .stats-card {
    background: var(--color-bg-elevated);
    padding: 1.5rem;
    border-radius: 8px;
    border: 1px solid var(--color-border);
  }
  
  .stats-card h3 {
    margin-bottom: 1rem;
    color: var(--color-text);
    font-size: 1rem;
  }
  
  .stat-row {
    display: flex;
    justify-content: space-between;
    padding: 0.75rem 0;
    border-bottom: 1px solid var(--color-border);
  }
  
  .stat-row:last-child {
    border-bottom: none;
  }
  
  .stat-label {
    color: var(--color-text-subtle);
    font-size: 0.9rem;
  }
  
  .stat-value {
    color: var(--color-primary);
    font-weight: 500;
  }
  
  /* RIGHT BRAIN STYLES */
  .right-brain {
    padding: 2rem;
    background: linear-gradient(135deg, rgba(212, 165, 116, 0.05) 0%, transparent 100%);
    border-radius: 12px;
    border-right: 3px solid var(--color-accent);
  }
  
  .rhythm-card {
    background: var(--color-bg-elevated);
    padding: 1.5rem;
    border-radius: 8px;
    border: 1px solid var(--color-border);
    margin-bottom: 1.5rem;
  }
  
  .rhythm-card h3 {
    margin-bottom: 1rem;
    color: var(--color-text);
    font-size: 1rem;
  }
  
  /* Rhythm Visualizer */
  .rhythm-visualizer {
    width: 100%;
    height: 150px;
    background: var(--color-bg);
    border-radius: 8px;
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
  }
  
  .pulse-particle {
    width: 60px;
    height: 60px;
    background: radial-gradient(circle, var(--color-accent) 0%, var(--color-accent-light) 100%);
    border-radius: 50%;
    box-shadow: 0 0 20px rgba(212, 165, 116, 0.5);
    transition: transform 0.1s ease-out;
  }
  
  .pulse-particle.pulsing {
    animation: pulse 1s ease-in-out infinite;
  }
  
  @keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.3); }
  }
  
  .rhythm-stats {
    display: grid;
    gap: 1rem;
    margin-top: 1rem;
  }
  
  .rhythm-stat {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem;
    background: var(--color-bg);
    border-radius: 6px;
  }
  
  .stat-icon {
    font-size: 1.5rem;
  }
  
  /* Spark Moments */
  .spark-moments-card {
    background: var(--color-bg-elevated);
    padding: 1.5rem;
    border-radius: 8px;
    border: 1px solid var(--color-border);
  }
  
  .spark-moments-card h3 {
    margin-bottom: 1rem;
    color: var(--color-text);
    font-size: 1rem;
  }
  
  .spark-moment {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
    background: var(--color-bg);
    border-radius: 6px;
    margin-bottom: 0.75rem;
  }
  
  .spark-icon {
    font-size: 1.5rem;
  }
  
  .spark-type {
    font-weight: 500;
    color: var(--color-text);
    margin-bottom: 0.25rem;
  }
  
  .spark-meta {
    font-size: 0.85rem;
    color: var(--color-text-subtle);
  }
  
  .no-rhythm {
    text-align: center;
    padding: 3rem 1rem;
    color: var(--color-text-subtle);
  }
  
  /* Content Section */
  .note-header {
    margin-bottom: 2rem;
  }
  
  .note-title {
    font-size: 2.5rem;
    margin-bottom: 1rem;
    line-height: 1.2;
  }
  
  .note-meta {
    display: flex;
    gap: 0.75rem;
    color: var(--color-text-subtle);
    font-size: 0.9rem;
    flex-wrap: wrap;
  }
  
  .note-content {
    background: var(--color-bg-elevated);
    padding: 3rem;
    border-radius: 12px;
    margin-bottom: 2rem;
    line-height: 1.8;
    font-size: 1.1rem;
    border: 1px solid var(--color-border);
  }
  
  .note-content p {
    margin-bottom: 1.5rem;
  }
  
  /* Quick Actions */
  .quick-actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    flex-wrap: wrap;
  }
  
  .action-btn {
    padding: 0.75rem 1.5rem;
    border-radius: 8px;
    border: none;
    font-size: 0.9rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s var(--ease-smooth);
    text-decoration: none;
    display: inline-block;
  }
  
  .action-edit {
    background: var(--color-primary);
    color: white;
  }
  
  .action-edit:hover {
    background: var(--color-primary-dark);
    transform: translateY(-2px);
  }
  
  .action-copy {
    background: rgba(91, 124, 153, 0.15);
    color: var(--color-text);
  }
  
  .action-copy:hover {
    background: rgba(91, 124, 153, 0.25);
  }
  
  .action-delete {
    background: rgba(193, 119, 103, 0.15);
    color: var(--color-error);
  }
  
  .action-delete:hover {
    background: var(--color-error);
    color: white;
  }
  
  /* Mobile Responsive */
  @media (max-width: 768px) {
    .cognitive-split {
      grid-template-columns: 1fr;
    }
    
    .note-content {
      padding: 2rem 1.5rem;
      font-size: 1rem;
    }
    
    .note-title {
      font-size: 2rem;
    }
  }
</style>

<script>
  // Rhythm playback
  let isPlaying = false;
  let animationFrame;
  
  const rhythmData = <%= raw @note.rhythm_events.ordered.to_json %>;
  
  function playRhythm() {
    if (isPlaying) {
      stopRhythm();
      return;
    }
    
    isPlaying = true;
    const btn = document.getElementById('playBtn');
    btn.textContent = '⏸️ Stop';
    
    const particle = document.getElementById('pulseParticle');
    particle.classList.add('pulsing');
    
    // Play through rhythm events
    let eventIndex = 0;
    
    function playNextEvent() {
      if (!isPlaying || eventIndex >= rhythmData.length) {
        stopRhythm();
        return;
      }
      
      const event = rhythmData[eventIndex];
      
      // Visual feedback based on event type
      if (event.event_type === 'pause') {
        particle.style.background = 'radial-gradient(circle, #D4A574 0%, #E8C9A1 100%)';
        particle.style.transform = 'scale(0.8)';
      } else if (event.event_type === 'burst') {
        particle.style.background = 'radial-gradient(circle, #5B7C99 0%, #7B9CB9 100%)';
        particle.style.transform = 'scale(1.5)';
        
        // Flash effect
        setTimeout(() => {
          particle.style.background = 'radial-gradient(circle, #D4A574 0%, #E8C9A1 100%)';
          particle.style.transform = 'scale(1)';
        }, 300);
      }
      
      eventIndex++;
      setTimeout(playNextEvent, 1000); // Play event every second
    }
    
    playNextEvent();
  }
  
  function stopRhythm() {
    isPlaying = false;
    const btn = document.getElementById('playBtn');
    btn.textContent = '▶️ Play Writing Rhythm';
    
    const particle = document.getElementById('pulseParticle');
    particle.classList.remove('pulsing');
    particle.style.transform = 'scale(1)';
    particle.style.background = 'radial-gradient(circle, var(--color-accent) 0%, var(--color-accent-light) 100%)';
  }
  
  // Copy to clipboard
  function copyToClipboard() {
    const content = `<%= @note.content.to_s.gsub(/\n/, '\\n').gsub(/'/, "\\\\'") %>`;
    navigator.clipboard.writeText(content).then(() => {
      showNotification('📋 Copied!');
    });
  }
  
  function showNotification(message) {
    const notification = document.createElement('div');
    notification.style.cssText = `
      position: fixed;
      bottom: 2rem;
      right: 2rem;
      background: var(--color-success);
      color: white;
      padding: 1rem 1.5rem;
      border-radius: 8px;
      box-shadow: var(--shadow-lg);
      z-index: 10000;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => notification.remove(), 2000);
  }
</script>
HTML

echo "✓ Complete cognitive dyad UI created"

echo ""
echo "======================================"
echo "✅ Complete System Ready!"
echo "======================================"
echo ""
echo "The Cognitive Dyad is now fully integrated:"
echo ""
echo "LEFT BRAIN (Analytical):"
echo "  📊 Structure detection badge"
echo "  📈 Word/sentence/time stats"
echo "  🎯 Thinking pattern identification"
echo ""
echo "RIGHT BRAIN (Rhythmic):"
echo "  🎵 BPM & rhythm signature"
echo "  ⚡ Spark moment detection"
echo "  🎬 Playable rhythm visualization"
echo "  🧘 Contemplation time tracking"
echo ""
echo "Integration:"
echo "  • Side-by-side view"
echo "  • Both working together"
echo "  • Mock VEPS generating rhythm data"
echo "  • Ready for real VEPS integration"
echo ""
echo "Run the foundation script first, then this one!"
echo ""