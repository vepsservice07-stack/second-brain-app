#!/bin/bash
set -e

echo "======================================"
echo "🔧 Adding Inline JavaScript (Bypass Importmap)"
echo "======================================"
echo ""

cd ~/Code/second-brain-app/second-brain-rails

# We'll add the JavaScript directly in the layout HTML
# This bypasses all importmap issues

# First, let's check if shared footer exists
mkdir -p app/views/shared

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

<!-- Inline JavaScript for keyboard shortcuts -->
<script>
  console.log('🚀 Keyboard shortcuts loading...');
  
  document.addEventListener('DOMContentLoaded', function() {
    console.log('⌨️  Setting up keyboard shortcuts...');
    
    document.addEventListener('keydown', function(e) {
      const activeElement = document.activeElement;
      const isInputField = activeElement.tagName === 'INPUT' || 
                          activeElement.tagName === 'TEXTAREA' || 
                          activeElement.isContentEditable;
      
      // / = Focus search
      if (e.key === '/' && !isInputField) {
        e.preventDefault();
        console.log('🔍 Slash pressed - focusing search');
        const searchInput = document.querySelector('input[name="search"]');
        if (searchInput) {
          searchInput.focus();
          console.log('✓ Search focused!');
        } else {
          console.log('⚠️ No search input found on this page');
        }
      }
      
      // n = New note
      if (e.key === 'n' && !isInputField) {
        e.preventDefault();
        console.log('📝 N pressed - going to new note');
        const newNoteLink = document.querySelector('a[href*="notes/new"]');
        if (newNoteLink) {
          console.log('✓ Found new note link:', newNoteLink.href);
          window.location.href = newNoteLink.href;
        } else {
          console.log('⚠️ New note link not found');
        }
      }
      
      // Escape = Clear
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
          const form = searchInput.closest('form');
          if (form) {
            window.location.href = form.action;
          }
        }
      }
    });
    
    console.log('✅ Keyboard shortcuts are ACTIVE!');
    console.log('Try pressing:');
    console.log('  / = Search');
    console.log('  n = New note');
    console.log('  ESC = Clear');
  });
</script>
HTML

echo "✓ Footer with inline JavaScript created"

echo ""
echo "======================================"
echo "✅ Inline JavaScript Added!"
echo "======================================"
echo ""
echo "This bypasses importmap completely!"
echo ""
echo "Now:"
echo "1. Just refresh your browser (F5 or Ctrl+R)"
echo "2. Open Console (F12)"
echo "3. You should see:"
echo "   🚀 Keyboard shortcuts loading..."
echo "   ⌨️  Setting up keyboard shortcuts..."
echo "   ✅ Keyboard shortcuts are ACTIVE!"
echo ""
echo "4. Try pressing / on the notes page"
echo ""
echo "No need to restart Rails!"
echo ""