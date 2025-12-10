#!/bin/bash
set -e

echo "======================================"
echo "🔧 Fixing Keyboard Shortcuts & Footer"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Update JavaScript to prevent browser defaults
cat > app/javascript/application.js << 'JS'
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Keyboard shortcuts - prevent browser defaults
document.addEventListener('turbo:load', function() {
  document.addEventListener('keydown', function(e) {
    // Only activate shortcuts when not in an input field
    const activeElement = document.activeElement;
    const isInputField = activeElement.tagName === 'INPUT' || 
                        activeElement.tagName === 'TEXTAREA' || 
                        activeElement.isContentEditable;
    
    // Cmd/Ctrl + K = Focus search (only when NOT in input)
    if ((e.metaKey || e.ctrlKey) && e.key === 'k' && !isInputField) {
      e.preventDefault();
      const searchInput = document.querySelector('input[name="search"]');
      if (searchInput) {
        searchInput.focus();
        searchInput.select();
      }
    }
    
    // / = Focus search (like GitHub, Twitter)
    if (e.key === '/' && !isInputField) {
      e.preventDefault();
      const searchInput = document.querySelector('input[name="search"]');
      if (searchInput) {
        searchInput.focus();
      }
    }
    
    // Escape = Clear search or blur input
    if (e.key === 'Escape') {
      if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
        activeElement.blur();
      }
      const searchInput = document.querySelector('input[name="search"]');
      if (searchInput && searchInput.value) {
        searchInput.value = '';
        // Trigger form submission to show all notes
        const form = searchInput.closest('form');
        if (form) {
          window.location.href = form.action;
        }
      }
    }
    
    // N = New note (when not in input)
    if (e.key === 'n' && !isInputField) {
      e.preventDefault();
      const newNoteLink = document.querySelector('a[href*="notes/new"]');
      if (newNoteLink) {
        window.location.href = newNoteLink.href;
      }
    }
  });
  
  // Show toast notification for shortcuts on first visit
  const hasSeenShortcuts = localStorage.getItem('seen_shortcuts');
  if (!hasSeenShortcuts && document.querySelector('.footer')) {
    setTimeout(() => {
      showShortcutHint();
      localStorage.setItem('seen_shortcuts', 'true');
    }, 2000);
  }
});

function showShortcutHint() {
  const hint = document.createElement('div');
  hint.style.cssText = `
    position: fixed;
    bottom: 80px;
    right: 20px;
    background: var(--color-primary);
    color: white;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    box-shadow: var(--shadow-lg);
    z-index: 1000;
    animation: slideUp 0.4s var(--ease-smooth);
  `;
  hint.innerHTML = `
    <div style="font-weight: 500; margin-bottom: 0.5rem;">💡 Keyboard Shortcuts Available!</div>
    <div style="font-size: 0.9rem; opacity: 0.9;">Press <strong>/</strong> to search, <strong>n</strong> for new note</div>
  `;
  document.body.appendChild(hint);
  
  setTimeout(() => {
    hint.style.transition = 'opacity 0.4s';
    hint.style.opacity = '0';
    setTimeout(() => hint.remove(), 400);
  }, 4000);
}
JS

echo "✓ Updated keyboard shortcuts (browser-friendly)"

# Update footer with correct shortcuts
cat > app/views/shared/_footer.html.erb << 'HTML'
<footer class="footer">
  <div class="footer-content">
    <div class="shortcuts">
      <div class="shortcut">
        <span class="kbd">/</span>
        <span>Search</span>
      </div>
      <div class="shortcut">
        <span class="kbd">n</span>
        <span>New Note</span>
      </div>
      <div class="shortcut">
        <span class="kbd">ESC</span>
        <span>Clear</span>
      </div>
    </div>
    <p class="text-subtle" style="font-size: 0.85rem;">
      Second Brain · Think Clearly
    </p>
  </div>
</footer>
HTML

echo "✓ Updated footer with correct shortcuts"

# Update application layout to use the partial
echo ""
echo "Updating layout to use footer partial..."

# We'll update just the footer section of the layout
# For now, create a quick script to do this
cat > /tmp/update_footer.rb << 'RUBY'
layout_path = 'app/views/layouts/application.html.erb'
content = File.read(layout_path)

# Replace the inline footer with the partial
old_footer = /<footer class="footer">.*?<\/footer>/m
new_footer = "<%= render 'shared/footer' if user_signed_in? %>"

content.gsub!(old_footer, new_footer)
File.write(layout_path, content)
puts "✓ Footer updated to use partial"
RUBY

ruby /tmp/update_footer.rb

echo ""
echo "======================================"
echo "✅ Shortcuts Fixed!"
echo "======================================"
echo ""
echo "New keyboard shortcuts (browser-friendly):"
echo "  / (forward slash) - Focus search"
echo "  n - New note"
echo "  ESC - Clear search or unfocus input"
echo ""
echo "These won't conflict with browser shortcuts!"
echo ""
echo "Refresh your browser to try them!"
echo ""