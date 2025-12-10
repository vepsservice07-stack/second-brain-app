#!/bin/bash
set -e

echo "======================================"
echo "🔧 Adding New Note Link to Navbar"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Update the footer to be smarter about which page you're on
cat > app/views/shared/_footer.html.erb << 'HTML'
<footer class="footer">
  <div class="footer-content">
    <div class="shortcuts">
      <% if controller_name == 'notes' && action_name == 'index' %>
        <div class="shortcut">
          <span class="kbd">/</span>
          <span>Search</span>
        </div>
      <% end %>
      
      <div class="shortcut">
        <span class="kbd">n</span>
        <span>New Note</span>
      </div>
      
      <% if controller_name == 'notes' && action_name == 'index' %>
        <div class="shortcut">
          <span class="kbd">ESC</span>
          <span>Clear</span>
        </div>
      <% end %>
      
      <div class="shortcut">
        <span class="kbd">?</span>
        <span>Help</span>
      </div>
    </div>
    <p class="text-subtle" style="font-size: 0.85rem;">
      Second Brain · Think Clearly
    </p>
  </div>
</footer>

<!-- Inline JavaScript for keyboard shortcuts -->
<script>
  console.log('🚀 Keyboard shortcuts loading...');
  
  document.addEventListener('DOMContentLoaded', function() {
    console.log('⌨️  Setting up keyboard shortcuts...');
    
    // Show help modal
    function showHelp() {
      const help = document.createElement('div');
      help.style.cssText = `
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: var(--color-bg-elevated);
        padding: 2rem;
        border-radius: 12px;
        box-shadow: var(--shadow-lg);
        z-index: 10000;
        min-width: 300px;
      `;
      help.innerHTML = `
        <h3 style="margin-bottom: 1rem;">Keyboard Shortcuts</h3>
        <div style="display: grid; gap: 0.75rem;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>Search notes</span>
            <span class="kbd">/</span>
          </div>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>New note</span>
            <span class="kbd">n</span>
          </div>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>Clear search</span>
            <span class="kbd">ESC</span>
          </div>
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span>Show help</span>
            <span class="kbd">?</span>
          </div>
        </div>
        <button onclick="this.parentElement.remove()" 
                style="margin-top: 1.5rem; width: 100%; padding: 0.75rem; background: var(--color-primary); color: white; border: none; border-radius: 6px; cursor: pointer;">
          Got it!
        </button>
      `;
      
      // Add backdrop
      const backdrop = document.createElement('div');
      backdrop.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0,0,0,0.5);
        z-index: 9999;
      `;
      backdrop.onclick = function() {
        backdrop.remove();
        help.remove();
      };
      
      document.body.appendChild(backdrop);
      document.body.appendChild(help);
    }
    
    document.addEventListener('keydown', function(e) {
      const activeElement = document.activeElement;
      const isInputField = activeElement.tagName === 'INPUT' || 
                          activeElement.tagName === 'TEXTAREA' || 
                          activeElement.isContentEditable;
      
      // ? = Show help
      if (e.key === '?' && !isInputField) {
        e.preventDefault();
        console.log('❓ Help requested');
        showHelp();
      }
      
      // / = Focus search (only on notes index)
      if (e.key === '/' && !isInputField) {
        e.preventDefault();
        console.log('🔍 Slash pressed - focusing search');
        const searchInput = document.querySelector('input[name="search"]');
        if (searchInput) {
          searchInput.focus();
          console.log('✓ Search focused!');
        } else {
          console.log('⚠️ No search on this page (that\'s okay)');
        }
      }
      
      // n = New note (works everywhere)
      if (e.key === 'n' && !isInputField) {
        e.preventDefault();
        console.log('📝 N pressed - going to new note');
        // Try multiple selectors
        const newNoteLink = document.querySelector('a[href="/notes/new"]') ||
                           document.querySelector('a[href*="notes/new"]') ||
                           document.querySelector('a.btn-primary');
        if (newNoteLink) {
          console.log('✓ Found new note link:', newNoteLink.href);
          window.location.href = newNoteLink.href;
        } else {
          console.log('⚠️ New note link not found, using direct path');
          window.location.href = '/notes/new';
        }
      }
      
      // Escape = Clear search or blur
      if (e.key === 'Escape') {
        console.log('🚪 Escape pressed');
        if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
          activeElement.blur();
          console.log('✓ Blurred input');
        }
        const searchInput = document.querySelector('input[name="search"]');
        if (searchInput && searchInput.value) {
          searchInput.value = '';
          console.log('✓ Cleared search');
          window.location.href = '/notes';
        }
      }
    });
    
    console.log('✅ Keyboard shortcuts are ACTIVE!');
    console.log('Try pressing:');
    console.log('  / = Search (on notes page)');
    console.log('  n = New note (works everywhere)');
    console.log('  ? = Show help');
  });
</script>
HTML

echo "✓ Footer updated with page-aware shortcuts"

echo ""
echo "======================================"
echo "✅ Shortcuts Fixed!"
echo "======================================"
echo ""
echo "Changes:"
echo "  ✓ 'n' now works on ANY page (goes to /notes/new)"
echo "  ✓ '/' only shows on notes page (where search exists)"
echo "  ✓ '?' shows help modal with all shortcuts"
echo ""
echo "Just refresh your browser!"
echo ""
echo "Try:"
echo "  Press 'n' from anywhere → New note"
echo "  Press '?' → See all shortcuts"
echo "  Press '/' on notes page → Focus search"
echo ""