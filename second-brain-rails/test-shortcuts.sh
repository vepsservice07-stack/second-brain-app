#!/bin/bash
set -e

echo "======================================"
echo "🔧 Ensuring JavaScript Shortcuts Work"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# Make sure the JavaScript file exists and is correct
echo "Step 1: Updating JavaScript file..."

cat > app/javascript/application.js << 'JS'
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

console.log('🚀 Second Brain JavaScript loaded!');

// Keyboard shortcuts - prevent browser defaults
document.addEventListener('turbo:load', function() {
  console.log('⌨️  Setting up keyboard shortcuts...');
  
  document.addEventListener('keydown', function(e) {
    // Only activate shortcuts when not in an input field
    const activeElement = document.activeElement;
    const isInputField = activeElement.tagName === 'INPUT' || 
                        activeElement.tagName === 'TEXTAREA' || 
                        activeElement.isContentEditable;
    
    // / = Focus search (like GitHub, Twitter)
    if (e.key === '/' && !isInputField) {
      e.preventDefault();
      console.log('🔍 Forward slash pressed - focusing search');
      const searchInput = document.querySelector('input[name="search"]');
      if (searchInput) {
        searchInput.focus();
        console.log('✓ Search focused!');
      } else {
        console.log('⚠ Search input not found');
      }
    }
    
    // n = New note (when not in input)
    if (e.key === 'n' && !isInputField) {
      e.preventDefault();
      console.log('📝 N pressed - going to new note');
      const newNoteLink = document.querySelector('a[href*="notes/new"]');
      if (newNoteLink) {
        window.location.href = newNoteLink.href;
      } else {
        console.log('⚠ New note link not found');
      }
    }
    
    // Escape = Clear search or blur input
    if (e.key === 'Escape') {
      console.log('🚪 Escape pressed');
      if (activeElement.tagName === 'INPUT' || activeElement.tagName === 'TEXTAREA') {
        activeElement.blur();
        console.log('✓ Input blurred');
      }
      const searchInput = document.querySelector('input[name="search"]');
      if (searchInput && searchInput.value) {
        searchInput.value = '';
        console.log('✓ Search cleared');
        // Trigger form submission to show all notes
        const form = searchInput.closest('form');
        if (form) {
          window.location.href = form.action;
        }
      }
    }
  });
  
  console.log('✓ Keyboard shortcuts active!');
  console.log('  Press / to search');
  console.log('  Press n for new note');
  console.log('  Press ESC to clear');
});
JS

echo "✓ JavaScript file updated with console logging"

echo ""
echo "======================================"
echo "✅ JavaScript Updated!"
echo "======================================"
echo ""
echo "Now do this:"
echo ""
echo "1. STOP your Rails server (Ctrl+C)"
echo "2. START it again: bin/rails server"
echo "3. Open browser and go to: http://localhost:3000"
echo "4. Open browser DevTools (F12 or Right-click > Inspect)"
echo "5. Go to the 'Console' tab"
echo "6. Refresh the page"
echo ""
echo "You should see:"
echo "  🚀 Second Brain JavaScript loaded!"
echo "  ⌨️  Setting up keyboard shortcuts..."
echo "  ✓ Keyboard shortcuts active!"
echo ""
echo "Then try pressing '/' - you should see console messages!"
echo ""
echo "If you DON'T see those messages, the JavaScript isn't loading."
echo "If you DO see them but shortcuts don't work, we'll debug further."
echo ""