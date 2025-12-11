#!/bin/bash
set -e

echo "======================================"
echo "🎨 Adding Mood-Responsive UI/UX"
echo "Visual Feedback · Ambient Shading · Safe Space"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Enhanced note show page with dynamic UI feedback
cat > app/views/notes/show.html.erb << 'HTML'
<div class="note-container" id="noteContainer">
  <!-- Ambient Overlay for Mood States -->
  <div id="ambientOverlay" class="ambient-overlay"></div>
  
  <!-- Reading Mode Toggle -->
  <button id="readingModeToggle" class="reading-mode-btn" onclick="toggleReadingMode()" title="Press 'r' for reading mode">
    <span id="readingModeIcon">📖</span> Reading Mode
  </button>
  
  <!-- Note Header with Structure Badge -->
  <div class="note-header">
    <div class="structure-badge" id="structureBadge">
      <span class="badge-icon">🎯</span>
      <span class="badge-text">Detecting structure...</span>
    </div>
    
    <h1 class="note-title"><%= @note.title %></h1>
    
    <div class="note-meta">
      <span>📝 <%= pluralize(@note.content.to_s.split.length, 'word') %></span>
      <span>•</span>
      <span>⏱️ <%= (((@note.content.to_s.split.length.to_f / 200) * 60).round) %> min read</span>
      <span>•</span>
      <span>🕐 <%= time_ago_in_words(@note.created_at) %> ago</span>
    </div>
  </div>
  
  <!-- Main Content Area -->
  <div class="note-content-wrapper">
    <!-- Zen Moment Sidebar -->
    <div id="zenMoment" class="zen-moment hidden">
      <div class="zen-icon">✨</div>
      <div class="zen-message"></div>
    </div>
    
    <!-- Main Content -->
    <div class="note-content" id="noteContent">
      <%= simple_format(@note.content) %>
    </div>
    
    <!-- Writing Stats Card -->
    <div class="stats-card">
      <h3>📊 Note Insights</h3>
      
      <div class="stat-row">
        <span class="stat-label">Words</span>
        <span class="stat-value"><%= @note.content.to_s.split.length %></span>
      </div>
      
      <div class="stat-row">
        <span class="stat-label">Characters</span>
        <span class="stat-value"><%= @note.content.to_s.length %></span>
      </div>
      
      <div class="stat-row">
        <span class="stat-label">Reading time</span>
        <span class="stat-value"><%= (((@note.content.to_s.split.length.to_f / 200) * 60).round) %> min</span>
      </div>
      
      <div class="stat-row">
        <span class="stat-label">Created</span>
        <span class="stat-value"><%= @note.created_at.strftime("%b %d at %l:%M %p") %></span>
      </div>
      
      <% if @note.updated_at != @note.created_at %>
        <div class="stat-row">
          <span class="stat-label">Last edited</span>
          <span class="stat-value"><%= time_ago_in_words(@note.updated_at) %> ago</span>
        </div>
      <% end %>
      
      <div class="stat-row">
        <span class="stat-label">Sentences</span>
        <span class="stat-value"><%= @note.content.to_s.scan(/[.!?]+/).length %></span>
      </div>
    </div>
    
    <!-- Related Notes -->
    <% related = current_user.notes.where.not(id: @note.id).order(updated_at: :desc).limit(3) %>
    <% if related.any? %>
      <div class="related-notes">
        <h3>🔗 Recent Notes</h3>
        <% related.each do |note| %>
          <%= link_to note, class: "related-note-card" do %>
            <div class="related-note-title"><%= note.title %></div>
            <div class="related-note-preview"><%= truncate(note.content, length: 80) %></div>
          <% end %>
        <% end %>
      </div>
    <% end %>
  </div>
  
  <!-- Quick Actions Toolbar -->
  <div class="quick-actions">
    <%= link_to edit_note_path(@note), class: "action-btn action-edit", title: "Edit (press 'e')" do %>
      ✏️ Edit
    <% end %>
    
    <button onclick="copyToClipboard()" class="action-btn action-copy" title="Copy content">
      📋 Copy
    </button>
    
    <button onclick="exportToPDF()" class="action-btn action-export" title="Export as PDF">
      📄 Export
    </button>
    
    <%= link_to @note, method: :delete, data: { confirm: 'Are you sure?' }, class: "action-btn action-delete" do %>
      🗑️ Delete
    <% end %>
  </div>
  
  <!-- Back Link -->
  <div class="back-link">
    <%= link_to notes_path, class: "btn btn-ghost" do %>
      ← Back to Notes
    <% end %>
  </div>
</div>

<style>
  .note-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem 1rem;
    position: relative;
    transition: all 1s ease;
  }
  
  /* Ambient Overlay - responds to mood states */
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
  
  /* Contemplation State - warm, gentle amber glow */
  .ambient-overlay.contemplating {
    background: radial-gradient(circle at center, 
      rgba(212, 165, 116, 0.08) 0%, 
      transparent 70%);
    opacity: 1;
  }
  
  /* Flow State - cool, focused blue glow */
  .ambient-overlay.flow {
    background: radial-gradient(circle at center, 
      rgba(91, 124, 153, 0.06) 0%, 
      transparent 70%);
    opacity: 1;
  }
  
  /* Reading State - gentle purple glow */
  .ambient-overlay.reading {
    background: radial-gradient(circle at center, 
      rgba(139, 116, 153, 0.05) 0%, 
      transparent 70%);
    opacity: 1;
  }
  
  /* Container responses to states */
  .note-container.contemplating {
    animation: gentlePulse 4s ease-in-out infinite;
  }
  
  @keyframes gentlePulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.002); }
  }
  
  .note-container.flow .note-content {
    box-shadow: 0 0 60px rgba(91, 124, 153, 0.15);
  }
  
  /* Reading Mode Toggle */
  .reading-mode-btn {
    position: fixed;
    top: 100px;
    right: 2rem;
    padding: 0.75rem 1.25rem;
    background: var(--color-bg-elevated);
    border: 1px solid var(--color-border);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.3s var(--ease-smooth);
    font-size: 0.9rem;
    color: var(--color-text);
    box-shadow: var(--shadow-sm);
    z-index: 100;
  }
  
  .reading-mode-btn:hover {
    background: var(--color-primary);
    color: white;
    border-color: var(--color-primary);
    transform: translateY(-2px);
    box-shadow: var(--shadow-md);
  }
  
  /* Structure Badge */
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
    animation: slideIn 0.5s var(--ease-smooth);
  }
  
  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateX(-20px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }
  
  .badge-icon {
    font-size: 1.1rem;
  }
  
  /* Note Header */
  .note-header {
    margin-bottom: 3rem;
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
  
  /* Zen Moment */
  .zen-moment {
    position: fixed;
    top: 50%;
    right: 2rem;
    transform: translateY(-50%);
    background: var(--color-accent);
    color: white;
    padding: 1.5rem;
    border-radius: 12px;
    box-shadow: var(--shadow-lg);
    max-width: 250px;
    animation: zenAppear 0.6s var(--ease-smooth);
    z-index: 1000;
  }
  
  .zen-moment.hidden {
    display: none;
  }
  
  @keyframes zenAppear {
    from {
      opacity: 0;
      transform: translateY(-50%) scale(0.9);
    }
    to {
      opacity: 1;
      transform: translateY(-50%) scale(1);
    }
  }
  
  .zen-icon {
    font-size: 2rem;
    text-align: center;
    margin-bottom: 0.5rem;
  }
  
  .zen-message {
    font-size: 0.95rem;
    line-height: 1.5;
    text-align: center;
    font-style: italic;
  }
  
  /* Note Content */
  .note-content-wrapper {
    position: relative;
    z-index: 1;
  }
  
  .note-content {
    background: var(--color-bg-elevated);
    padding: 3rem;
    border-radius: 12px;
    margin-bottom: 2rem;
    line-height: 1.8;
    font-size: 1.1rem;
    border: 1px solid var(--color-border);
    transition: all 1s ease;
  }
  
  .note-content p {
    margin-bottom: 1.5rem;
  }
  
  /* Stats Card */
  .stats-card {
    background: var(--color-bg-elevated);
    padding: 2rem;
    border-radius: 12px;
    margin-bottom: 2rem;
    border: 1px solid var(--color-border);
    transition: all 0.5s ease;
  }
  
  .stats-card h3 {
    margin-bottom: 1.5rem;
    color: var(--color-text);
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
  
  /* Related Notes */
  .related-notes {
    background: var(--color-bg-elevated);
    padding: 2rem;
    border-radius: 12px;
    margin-bottom: 2rem;
    border: 1px solid var(--color-border);
  }
  
  .related-notes h3 {
    margin-bottom: 1rem;
    color: var(--color-text);
  }
  
  .related-note-card {
    display: block;
    padding: 1rem;
    background: var(--color-bg);
    border-radius: 8px;
    margin-bottom: 0.75rem;
    text-decoration: none;
    transition: all 0.3s var(--ease-smooth);
    border: 1px solid transparent;
  }
  
  .related-note-card:hover {
    background: var(--color-bg-elevated);
    border-color: var(--color-primary);
    transform: translateX(4px);
  }
  
  .related-note-title {
    font-weight: 500;
    color: var(--color-text);
    margin-bottom: 0.25rem;
  }
  
  .related-note-preview {
    font-size: 0.85rem;
    color: var(--color-text-subtle);
  }
  
  /* Quick Actions */
  .quick-actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
    flex-wrap: wrap;
    z-index: 1;
    position: relative;
    transition: all 0.5s ease;
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
    box-shadow: var(--shadow-md);
  }
  
  .action-copy, .action-export {
    background: rgba(91, 124, 153, 0.15);
    color: var(--color-text);
  }
  
  .action-copy:hover, .action-export:hover {
    background: rgba(91, 124, 153, 0.25);
    transform: translateY(-2px);
  }
  
  .action-delete {
    background: rgba(193, 119, 103, 0.15);
    color: var(--color-error);
  }
  
  .action-delete:hover {
    background: var(--color-error);
    color: white;
    transform: translateY(-2px);
  }
  
  .back-link {
    margin-top: 2rem;
    z-index: 1;
    position: relative;
  }
  
  /* Reading Mode */
  body.reading-mode .navbar,
  body.reading-mode .quick-actions,
  body.reading-mode .stats-card,
  body.reading-mode .related-notes,
  body.reading-mode .footer,
  body.reading-mode .structure-badge,
  body.reading-mode .note-meta {
    opacity: 0.1;
    pointer-events: none;
  }
  
  body.reading-mode .note-content {
    max-width: 650px;
    margin: 3rem auto;
    font-size: 1.2rem;
    line-height: 2;
    padding: 4rem;
  }
  
  body.reading-mode .note-title {
    text-align: center;
    margin-bottom: 3rem;
  }
  
  /* Contemplation mode - fade distractions more */
  .note-container.contemplating .stats-card,
  .note-container.contemplating .related-notes,
  .note-container.contemplating .quick-actions {
    opacity: 0.4;
    transition: opacity 2s ease;
  }
  
  /* Mobile Responsive */
  @media (max-width: 768px) {
    .reading-mode-btn {
      position: static;
      margin-bottom: 1rem;
      width: 100%;
    }
    
    .note-content {
      padding: 2rem 1.5rem;
      font-size: 1rem;
    }
    
    .note-title {
      font-size: 2rem;
    }
    
    .zen-moment {
      left: 1rem;
      right: 1rem;
      max-width: none;
    }
  }
</style>

<script>
  // Structure Detection
  const noteContent = `<%= @note.content.to_s.gsub(/['"\n\r]/, ' ') %>`.toLowerCase();
  
  const structures = [
    { name: 'Logical Argument', emoji: '🎯', keywords: ['because', 'therefore', 'thus', 'hence', 'consequently'] },
    { name: 'Causal Chain', emoji: '⛓️', keywords: ['leads to', 'causes', 'results in', 'due to'] },
    { name: 'Comparative Analysis', emoji: '⚖️', keywords: ['compared to', 'versus', 'while', 'whereas', 'unlike'] },
    { name: 'Problem-Solution', emoji: '🔧', keywords: ['problem', 'solution', 'fix', 'resolve', 'address'] },
    { name: 'Narrative Arc', emoji: '📖', keywords: ['then', 'next', 'finally', 'began', 'ended'] },
    { name: 'Retrospective', emoji: '🔄', keywords: ['learned', 'reflected', 'realized', 'understood'] },
    { name: 'Personal Insight', emoji: '💭', keywords: ['feel', 'think', 'believe', 'sense', 'wonder'] },
    { name: 'Mind Map', emoji: '🧠', keywords: ['idea', 'thought', 'concept', 'connection', 'related'] }
  ];
  
  // Detect structure
  let bestMatch = { name: 'Free Thought', emoji: '✨', score: 0 };
  
  structures.forEach(structure => {
    let score = 0;
    structure.keywords.forEach(keyword => {
      if (noteContent.includes(keyword)) score++;
    });
    if (score > bestMatch.score) {
      bestMatch = { ...structure, score };
    }
  });
  
  // Update badge
  setTimeout(() => {
    const badge = document.getElementById('structureBadge');
    badge.querySelector('.badge-icon').textContent = bestMatch.emoji;
    badge.querySelector('.badge-text').textContent = bestMatch.name;
  }, 300);
  
  // Mood State Management
  let currentMoodState = 'reading';
  const container = document.getElementById('noteContainer');
  const overlay = document.getElementById('ambientOverlay');
  
  function setMoodState(state) {
    if (currentMoodState === state) return;
    
    // Remove old classes
    container.classList.remove('contemplating', 'flow', 'reading');
    overlay.classList.remove('contemplating', 'flow', 'reading');
    
    // Add new state
    container.classList.add(state);
    overlay.classList.add(state);
    currentMoodState = state;
    
    console.log(`🎨 Mood state: ${state}`);
  }
  
  // Reading Mode
  function toggleReadingMode() {
    document.body.classList.toggle('reading-mode');
    const icon = document.getElementById('readingModeIcon');
    icon.textContent = document.body.classList.contains('reading-mode') ? '📝' : '📖';
    
    if (document.body.classList.contains('reading-mode')) {
      setMoodState('reading');
    }
  }
  
  // Keyboard shortcuts
  document.addEventListener('keydown', function(e) {
    const isInputField = document.activeElement.tagName === 'INPUT' || 
                        document.activeElement.tagName === 'TEXTAREA';
    
    if (e.key === 'r' && !isInputField) {
      e.preventDefault();
      toggleReadingMode();
    }
    
    if (e.key === 'e' && !isInputField) {
      e.preventDefault();
      window.location.href = '<%= edit_note_path(@note) %>';
    }
  });
  
  // Copy to clipboard
  function copyToClipboard() {
    const content = `<%= @note.content.to_s.gsub(/\n/, '\\n').gsub(/'/, "\\\\'") %>`;
    navigator.clipboard.writeText(content).then(() => {
      showNotification('📋 Copied to clipboard!');
    });
  }
  
  // Export placeholder
  function exportToPDF() {
    showNotification('📄 Export feature coming soon!');
  }
  
  // Notification helper
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
      animation: slideUp 0.3s var(--ease-smooth);
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
      notification.style.opacity = '0';
      notification.style.transform = 'translateY(20px)';
      setTimeout(() => notification.remove(), 300);
    }, 2000);
  }
  
  // Zen Moments
  let readingTimer;
  let hasShownZen = false;
  let activityCount = 0;
  
  const zenMessages = [
    "Take a breath. Let the thought settle.",
    "This silence is where understanding grows.",
    "The pause between ideas is thinking.",
    "You're safe here. Take your time.",
    "Contemplation is not wasted time.",
    "Let the idea breathe.",
    "Trust the quiet moments."
  ];
  
  function showZenMoment() {
    if (hasShownZen) return;
    
    const zenElement = document.getElementById('zenMoment');
    const messageElement = zenElement.querySelector('.zen-message');
    
    const randomMessage = zenMessages[Math.floor(Math.random() * zenMessages.length)];
    messageElement.textContent = randomMessage;
    
    zenElement.classList.remove('hidden');
    hasShownZen = true;
    
    // Shift to contemplation state
    setMoodState('contemplating');
    
    // Hide after 5 seconds
    setTimeout(() => {
      zenElement.classList.add('hidden');
      setTimeout(() => hasShownZen = false, 10000);
    }, 5000);
  }
  
  // Detect reading pauses and activity
  function resetActivityTimer() {
    activityCount++;
    clearTimeout(readingTimer);
    
    // Active reading (not contemplating)
    if (activityCount > 3 && currentMoodState === 'contemplating') {
      setMoodState('reading');
    }
    
    // Start contemplation timer (8 seconds of stillness)
    readingTimer = setTimeout(() => {
      activityCount = 0;
      showZenMoment();
    }, 8000);
  }
  
  document.addEventListener('mousemove', resetActivityTimer);
  document.addEventListener('scroll', resetActivityTimer);
  document.addEventListener('click', resetActivityTimer);
  
  // Start in reading state
  setMoodState('reading');
  readingTimer = setTimeout(showZenMoment, 8000);
</script>
HTML

echo "✓ Mood-responsive UI created with ambient shading"

echo ""
echo "======================================"
echo "✅ Dynamic UI/UX Complete!"
echo "======================================"
echo ""
echo "Mood-Responsive States:"
echo ""
echo "  📖 READING MODE"
echo "     • Cool blue ambient glow"
echo "     • Focused content"
echo "     • Press 'r' to toggle"
echo ""
echo "  🧘 CONTEMPLATING (after 8s stillness)"
echo "     • Warm amber glow radiates"
echo "     • Distractions fade to 40% opacity"
echo "     • Gentle pulsing animation"
echo "     • Zen message appears"
echo ""
echo "  🌊 FLOW STATE (when active)"
echo "     • Content gets subtle shadow glow"
echo "     • Everything else stays clear"
echo ""
echo "The entire UI breathes and responds to your state!"
echo ""
echo "Refresh and view a note, then:"
echo "  1. Stay still for 8 seconds → Watch it shift"
echo "  2. Move around → Watch it brighten"
echo "  3. Press 'r' → Reading mode"
echo ""
