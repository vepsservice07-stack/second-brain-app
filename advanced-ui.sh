#!/bin/bash
# Second Brain - Advanced UI (Dark Mode + Power User Features)
# High contrast, low eye strain, keyboard-first
# Usage: ./advanced-ui.sh

echo "========================================"
echo "  Advanced UI Setup"
echo "========================================"
echo ""

cd second-brain-rails

echo "Creating advanced dark theme..."

cat > app/assets/stylesheets/custom.css << 'CSS'
/* Dark, high-contrast theme for reduced eye strain */
:root {
  --bg-primary: #0A0E1A;
  --bg-secondary: #111827;
  --bg-tertiary: #1F2937;
  --bg-hover: #374151;
  
  --text-primary: #F9FAFB;
  --text-secondary: #D1D5DB;
  --text-tertiary: #9CA3AF;
  
  --accent: #6366F1;
  --accent-bright: #818CF8;
  --accent-dim: #4F46E5;
  
  --border: #374151;
  --border-subtle: #1F2937;
  
  --success: #10B981;
  --warning: #F59E0B;
  --danger: #EF4444;
  
  --mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', 'Monaco', 'Inconsolata', monospace;
  --sans: -apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', sans-serif;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--sans);
  background: var(--bg-primary);
  color: var(--text-primary);
  font-size: 14px;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

/* Smooth scrolling */
html {
  scroll-behavior: smooth;
}

/* Selection color */
::selection {
  background: var(--accent);
  color: var(--text-primary);
}

/* Links */
a {
  color: var(--accent-bright);
  text-decoration: none;
  transition: color 0.15s ease;
}

a:hover {
  color: var(--text-primary);
}

/* Monospace everywhere for content */
.note-content,
textarea,
pre,
code {
  font-family: var(--mono);
  font-size: 13px;
  line-height: 1.7;
}

/* Input styling */
input[type="text"],
input[type="email"],
input[type="password"],
textarea,
select {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  color: var(--text-primary);
  padding: 8px 12px;
  border-radius: 4px;
  font-family: var(--mono);
  transition: all 0.15s ease;
}

input:focus,
textarea:focus,
select:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1);
}

input::placeholder,
textarea::placeholder {
  color: var(--text-tertiary);
}

/* Buttons */
button,
.btn {
  font-family: var(--mono);
  font-size: 12px;
  padding: 6px 12px;
  border-radius: 4px;
  border: 1px solid var(--border);
  background: var(--bg-secondary);
  color: var(--text-secondary);
  cursor: pointer;
  transition: all 0.15s ease;
}

button:hover,
.btn:hover {
  background: var(--bg-hover);
  border-color: var(--accent);
  color: var(--text-primary);
}

.btn-primary {
  background: var(--accent);
  border-color: var(--accent);
  color: var(--text-primary);
}

.btn-primary:hover {
  background: var(--accent-bright);
  border-color: var(--accent-bright);
}

.btn-danger {
  color: var(--danger);
  border-color: var(--danger);
}

.btn-danger:hover {
  background: rgba(239, 68, 68, 0.1);
}

/* Cards */
.card {
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  border-radius: 6px;
  transition: all 0.15s ease;
}

.card:hover {
  border-color: var(--border);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

/* Note cards with left accent */
.note-card {
  background: var(--bg-secondary);
  border-left: 2px solid var(--accent);
  padding: 12px 16px;
  margin-bottom: 8px;
  transition: all 0.12s ease;
}

.note-card:hover {
  background: var(--bg-tertiary);
  border-left-width: 3px;
  transform: translateX(2px);
}

/* Navigation */
nav {
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--border);
  backdrop-filter: blur(8px);
  position: sticky;
  top: 0;
  z-index: 100;
}

/* Keyboard shortcuts indicator */
.kbd {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 2px 6px;
  font-family: var(--mono);
  font-size: 10px;
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-radius: 3px;
  color: var(--text-tertiary);
  min-width: 20px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.3);
}

/* Meta information */
.meta {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--text-tertiary);
  letter-spacing: 0.01em;
}

/* Tags */
.tag-pill {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
  font-size: 10px;
  font-weight: 500;
  border-radius: 3px;
  font-family: var(--mono);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: 1px solid;
}

/* Status dots */
.status-dot {
  display: inline-block;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  margin-right: 8px;
}

.status-active { background: var(--success); box-shadow: 0 0 8px var(--success); }
.status-draft { background: var(--warning); }
.status-archived { background: var(--text-tertiary); }

/* Scrollbar styling */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--bg-primary);
}

::-webkit-scrollbar-thumb {
  background: var(--border);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--bg-hover);
}

/* Focus ring for accessibility */
*:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}

/* Toast notifications */
.toast {
  position: fixed;
  bottom: 24px;
  right: 24px;
  background: var(--bg-tertiary);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 12px 16px;
  font-family: var(--mono);
  font-size: 12px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
  animation: slideIn 0.2s ease;
  z-index: 1000;
}

@keyframes slideIn {
  from {
    transform: translateY(100%);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

.toast-success { border-left: 3px solid var(--success); }
.toast-error { border-left: 3px solid var(--danger); }

/* Code blocks */
pre {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: 4px;
  padding: 12px;
  overflow-x: auto;
}

code {
  background: var(--bg-tertiary);
  padding: 2px 6px;
  border-radius: 3px;
  font-size: 12px;
}

/* Stats grid */
.stat-card {
  background: var(--bg-secondary);
  border: 1px solid var(--border-subtle);
  padding: 20px;
  border-radius: 6px;
  position: relative;
  overflow: hidden;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, var(--accent), var(--accent-bright));
}

.stat-value {
  font-family: var(--mono);
  font-size: 32px;
  font-weight: 600;
  color: var(--text-primary);
  line-height: 1;
}

/* Shortcuts panel */
.shortcuts {
  background: var(--bg-secondary);
  border: 1px solid var(--border);
  border-radius: 6px;
  padding: 12px;
}

.shortcut-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 6px 0;
  font-size: 12px;
}

/* Sequence number badge */
.seq-badge {
  font-family: var(--mono);
  font-size: 10px;
  color: var(--text-tertiary);
  background: var(--bg-primary);
  padding: 2px 6px;
  border-radius: 3px;
  border: 1px solid var(--border);
}

/* Loading states */
.loading {
  opacity: 0.5;
  pointer-events: none;
}

/* Minimal form labels */
label {
  font-family: var(--mono);
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--text-tertiary);
  display: block;
  margin-bottom: 6px;
}

/* Better textarea */
textarea {
  resize: vertical;
  min-height: 300px;
  font-size: 13px;
  line-height: 1.8;
}

/* Hover effects on interactive elements */
.interactive {
  cursor: pointer;
  transition: all 0.12s ease;
}

.interactive:hover {
  transform: translateY(-1px);
}

/* Grid layouts */
.grid-auto {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 16px;
}

/* Utility classes */
.text-accent { color: var(--accent-bright); }
.text-muted { color: var(--text-tertiary); }
.text-mono { font-family: var(--mono); }
.border-accent { border-color: var(--accent); }
.bg-highlight { background: var(--bg-tertiary); }

/* Print styles */
@media print {
  body {
    background: white;
    color: black;
  }
  nav, .btn { display: none; }
}

/* Reduce motion for accessibility */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
CSS

echo "✅ Advanced dark theme created"
echo ""

echo "Creating keyboard shortcuts helper..."

cat > app/views/shared/_keyboard_shortcuts.html.erb << 'ERB'
<div class="fixed bottom-4 right-4 shortcuts" style="display: none;" id="shortcuts-panel">
  <div class="text-xs font-mono mb-2 text-gray-400">keyboard shortcuts</div>
  <div class="space-y-1">
    <div class="shortcut-item">
      <span>new note</span>
      <span class="kbd">⌘K</span>
    </div>
    <div class="shortcut-item">
      <span>all notes</span>
      <span class="kbd">⌘/</span>
    </div>
    <div class="shortcut-item">
      <span>search</span>
      <span class="kbd">⌘P</span>
    </div>
    <div class="shortcut-item">
      <span>this menu</span>
      <span class="kbd">?</span>
    </div>
  </div>
</div>
ERB

echo "✅ Keyboard shortcuts helper created"
echo ""

echo "Updating layout with enhanced features..."

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
          </div>
        </div>
        <div style="display: flex; align-items: center; gap: 12px;">
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
      // Enhanced keyboard shortcuts
      document.addEventListener('keydown', (e) => {
        // Don't trigger if typing in input
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') return;
        
        // ⌘K or Ctrl+K - New note
        if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
          e.preventDefault();
          window.location.href = '<%= new_note_path %>';
        }
        
        // ⌘/ or Ctrl+/ - All notes
        if ((e.metaKey || e.ctrlKey) && e.key === '/') {
          e.preventDefault();
          window.location.href = '<%= notes_path %>';
        }
        
        // ? - Toggle shortcuts panel
        if (e.key === '?') {
          e.preventDefault();
          const panel = document.getElementById('shortcuts-panel');
          panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
        }
        
        // Escape - Close shortcuts panel
        if (e.key === 'Escape') {
          document.getElementById('shortcuts-panel').style.display = 'none';
        }
      });
      
      // Auto-save indicator
      let saveTimeout;
      document.querySelectorAll('textarea, input[type="text"]').forEach(el => {
        el.addEventListener('input', () => {
          clearTimeout(saveTimeout);
          el.style.borderColor = 'var(--warning)';
          saveTimeout = setTimeout(() => {
            el.style.borderColor = 'var(--border)';
          }, 1000);
        });
      });
    </script>
  </body>
</html>
ERB

echo "✅ Enhanced layout created"
echo ""

echo "========================================"
echo "  Advanced UI Complete!"
echo "========================================"
echo ""
echo "Features added:"
echo "  🌙 Full dark mode (reduced eye strain)"
echo "  ⌨️  Enhanced keyboard shortcuts"
echo "  🎨 High contrast color scheme"
echo "  💫 Smooth micro-interactions"
echo "  🔤 Monospace everywhere"
echo "  📊 Sequence numbers prominent"
echo "  ⚡ Optimized for speed"
echo "  🎯 Focus on content, minimal chrome"
echo ""
echo "Keyboard shortcuts:"
echo "  ⌘K  - New note"
echo "  ⌘/  - All notes"
echo "  ?   - Show this help"
echo ""
echo "Refresh your browser!"
echo ""