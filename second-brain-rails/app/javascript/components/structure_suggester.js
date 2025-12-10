// Real-time structure suggestion overlay
// Shows formal structure options as you type

export class StructureSuggester {
  constructor(noteId, textareaElement) {
    this.noteId = noteId;
    this.textarea = textareaElement;
    this.suggestionsPanel = null;
    this.currentSuggestions = null;
    this.debounceTimer = null;
    
    this.init();
  }
  
  init() {
    // Create suggestions panel
    this.createSuggestionsPanel();
    
    // Listen for typing
    this.textarea.addEventListener('input', () => {
      this.debouncedUpdate();
    });
    
    // Keyboard shortcuts
    this.textarea.addEventListener('keydown', (e) => {
      this.handleKeyboard(e);
    });
  }
  
  createSuggestionsPanel() {
    const panel = document.createElement('div');
    panel.className = 'structure-suggestions-panel';
    panel.style.cssText = `
      position: absolute;
      right: 20px;
      top: 100px;
      width: 300px;
      background: rgba(0, 0, 0, 0.9);
      border: 1px solid #333;
      border-radius: 8px;
      padding: 16px;
      display: none;
      z-index: 1000;
    `;
    
    document.body.appendChild(panel);
    this.suggestionsPanel = panel;
  }
  
  debouncedUpdate() {
    clearTimeout(this.debounceTimer);
    this.debounceTimer = setTimeout(() => {
      this.updateSuggestions();
    }, 1000); // Wait 1s after typing stops
  }
  
  async updateSuggestions() {
    try {
      const response = await fetch(`/notes/${this.noteId}/structure_suggestions`);
      const data = await response.json();
      
      this.currentSuggestions = data;
      this.renderSuggestions(data);
    } catch (error) {
      console.error('Error fetching suggestions:', error);
    }
  }
  
  renderSuggestions(data) {
    if (!data.suggestions || data.suggestions.length === 0) {
      this.suggestionsPanel.style.display = 'none';
      return;
    }
    
    const html = `
      <div class="suggestions-header">
        <h4>Structure Suggestions</h4>
        <div class="cognitive-state">
          State: ${data.semantic_analysis.cognitive_state}
          ${data.semantic_analysis.flow_state ? '🔥' : ''}
        </div>
      </div>
      
      <div class="suggestions-list">
        ${data.suggestions.map((s, idx) => `
          <div class="suggestion-item" data-index="${idx}">
            <div class="suggestion-header">
              <span class="suggestion-name">${s.structure.name}</span>
              <span class="suggestion-confidence">
                ${Math.round(s.structure.confidence * 100)}%
              </span>
              <kbd>${idx + 1}</kbd>
            </div>
            <div class="suggestion-example">
              ${s.structure.example}
            </div>
          </div>
        `).join('')}
      </div>
      
      <div class="suggestions-footer">
        Press 1-3 to apply structure, Esc to hide
      </div>
    `;
    
    this.suggestionsPanel.innerHTML = html;
    this.suggestionsPanel.style.display = 'block';
    
    // Add click handlers
    this.suggestionsPanel.querySelectorAll('.suggestion-item').forEach((item) => {
      item.addEventListener('click', () => {
        const index = parseInt(item.dataset.index);
        this.applyStructure(index);
      });
    });
  }
  
  handleKeyboard(e) {
    // Check for number keys 1-3
    if (e.key >= '1' && e.key <= '3' && e.altKey) {
      e.preventDefault();
      const index = parseInt(e.key) - 1;
      this.applyStructure(index);
    }
    
    // Esc to hide
    if (e.key === 'Escape') {
      this.suggestionsPanel.style.display = 'none';
    }
  }
  
  async applyStructure(index) {
    if (!this.currentSuggestions || !this.currentSuggestions.suggestions[index]) {
      return;
    }
    
    const suggestion = this.currentSuggestions.suggestions[index];
    const structureType = suggestion.structure.template;
    
    try {
      const response = await fetch(`/notes/${this.noteId}/apply_structure`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        },
        body: JSON.stringify({
          structure_type: structureType,
          modifications: {}
        })
      });
      
      const data = await response.json();
      
      if (data.success) {
        this.insertStructure(data.formatted_content);
        this.suggestionsPanel.style.display = 'none';
      }
    } catch (error) {
      console.error('Error applying structure:', error);
    }
  }
  
  insertStructure(formattedContent) {
    // Insert structured template into textarea
    const template = formattedContent.map(element => {
      return `${element.element.toUpperCase()}:\n${element.content || element.placeholder}\n`;
    }).join('\n');
    
    // Insert at current cursor position
    const start = this.textarea.selectionStart;
    const end = this.textarea.selectionEnd;
    const text = this.textarea.value;
    
    this.textarea.value = text.substring(0, start) + '\n\n' + template + '\n\n' + text.substring(end);
    
    // Trigger input event for VEPS capture
    this.textarea.dispatchEvent(new Event('input', { bubbles: true }));
  }
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
  const noteTextarea = document.querySelector('textarea[data-note-id]');
  if (noteTextarea) {
    const noteId = noteTextarea.dataset.noteId;
    new StructureSuggester(noteId, noteTextarea);
  }
});
