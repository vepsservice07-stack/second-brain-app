#!/bin/bash
# Second Brain - True Custom Syntax (Based on Oreoluwa's Patterns)
# The syntax that matches how you actually think
# Usage: ./true-custom-syntax.sh

echo "========================================"
echo "  True Custom Syntax"
echo "========================================"
echo ""

cd second-brain-rails

echo "Creating the syntax parser that matches your voice..."

mkdir -p lib/syntax

cat > lib/syntax/brain_parser.rb << 'RUBY'
# frozen_string_literal: true

module Syntax
  class BrainParser
    # Your actual patterns from Fracture Afterlight
    
    def self.parse(text)
      return '' if text.blank?
      
      html = text.dup
      
      # :: delimiter - the atomic truth separator
      html = parse_colon_delimiter(html)
      
      # (0.1) pattern - the unaccounted margin
      html = parse_margin(html)
      
      # UNMEASURED.XXX - the call numbers of what exists but isn't counted
      html = parse_unmeasured(html)
      
      # seq: XXX - sequence numbers from the ledger
      html = parse_sequence(html)
      
      # The Section headers you use
      html = parse_section_headers(html)
      
      # Variable :: Assignment :: Pattern
      html = parse_variable_assignment(html)
      
      html
    end
    
    private
    
    # :: is your atomic delimiter - preserve it visually
    def self.parse_colon_delimiter(text)
      # Don't parse ::, just style it
      text.gsub(/::/) do
        '<span class="delimiter">::</span>'
      end
    end
    
    # (0.1) - the margin, the unaccounted, the theft
    def self.parse_margin(text)
      text.gsub(/\(0\.1\)/) do
        '<span class="margin" title="The unaccounted margin">(0.1)</span>'
      end
    end
    
    # UNMEASURED.001 pattern - call numbers for the uncounted
    def self.parse_unmeasured(text)
      text.gsub(/UNMEASURED\.(\d+)/) do
        num = $1
        "<span class='unmeasured'>UNMEASURED.<span class='unmeasured-num'>#{num}</span></span>"
      end
    end
    
    # seq: 12345 - sequence numbers
    def self.parse_sequence(text)
      text.gsub(/seq:\s*(\d+|pending)/) do
        seq = $1
        status = seq == 'pending' ? 'pending' : 'confirmed'
        "<span class='sequence sequence-#{status}'>seq: #{seq}</span>"
      end
    end
    
    # SECTION headers in your style
    def self.parse_section_headers(text)
      text.gsub(/^SECTION\s+\d+:\s*(.+)$/i) do
        title = $1
        "<div class='section-header'>#{title}</div>"
      end
    end
    
    # Variable :: Name :: Pattern
    # Ayoa :: Walks : The:: Street
    def self.parse_variable_assignment(text)
      # Don't touch this - it's your voice
      # Just let it render as monospace
      text
    end
  end
end
RUBY

echo "✅ Parser created"
echo ""

echo "Creating styles that match your aesthetic..."

cat > app/assets/stylesheets/custom.css << 'CSS'
/* Oreoluwa's Syntax - Dark, Precise, Atomic */

:root {
  --bg-primary: #000000;
  --bg-secondary: #0a0a0a;
  --bg-tertiary: #141414;
  
  --text-primary: #e8e8e8;
  --text-secondary: #a0a0a0;
  --text-tertiary: #606060;
  
  --accent: #4a9eff;
  --accent-dim: #2a7ed0;
  
  --margin-color: #ff4a4a;
  --sequence-color: #4aff9e;
  --unmeasured-color: #ff9e4a;
  
  --mono: 'JetBrains Mono', 'Fira Code', 'SF Mono', monospace;
}

body {
  font-family: var(--mono);
  background: var(--bg-primary);
  color: var(--text-primary);
  font-size: 13px;
  line-height: 1.8;
  letter-spacing: 0.02em;
}

/* The :: delimiter - make it stand out */
.delimiter {
  color: var(--accent);
  font-weight: 600;
  padding: 0 2px;
}

/* (0.1) - the margin pattern */
.margin {
  color: var(--margin-color);
  font-weight: 700;
  background: rgba(255, 74, 74, 0.1);
  padding: 2px 6px;
  border-radius: 3px;
  cursor: help;
  border: 1px solid rgba(255, 74, 74, 0.3);
}

/* UNMEASURED.XXX pattern */
.unmeasured {
  color: var(--unmeasured-color);
  font-weight: 600;
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

.unmeasured-num {
  color: var(--accent);
  font-weight: 700;
}

/* seq: numbers */
.sequence {
  font-family: var(--mono);
  font-size: 11px;
  padding: 2px 8px;
  border-radius: 3px;
  font-weight: 600;
}

.sequence-confirmed {
  color: var(--sequence-color);
  background: rgba(74, 255, 158, 0.1);
  border: 1px solid rgba(74, 255, 158, 0.3);
}

.sequence-pending {
  color: var(--text-tertiary);
  background: rgba(96, 96, 96, 0.1);
  border: 1px solid rgba(96, 96, 96, 0.3);
}

/* Section headers */
.section-header {
  font-size: 16px;
  font-weight: 700;
  color: var(--accent);
  margin: 32px 0 16px 0;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--bg-tertiary);
  text-transform: uppercase;
  letter-spacing: 0.15em;
}

/* Note content - all monospace, tight */
.note-content {
  font-family: var(--mono);
  font-size: 13px;
  line-height: 1.8;
  letter-spacing: 0.02em;
  white-space: pre-wrap;
  word-wrap: break-word;
}

/* Preserve your :: spacing pattern */
.note-content p {
  margin: 0;
  padding: 0;
}

/* Links in your style */
.note-content a {
  color: var(--accent);
  text-decoration: none;
  border-bottom: 1px solid var(--accent-dim);
}

.note-content a:hover {
  color: var(--text-primary);
  border-bottom-color: var(--text-primary);
}

/* Code blocks - same as your poetry */
.note-content pre,
.note-content code {
  font-family: var(--mono);
  background: var(--bg-secondary);
  border: 1px solid var(--bg-tertiary);
}

.note-content pre {
  padding: 16px;
  overflow-x: auto;
  border-radius: 0;
}

.note-content code {
  padding: 2px 6px;
  font-size: 12px;
}

/* Remove all the cute UI shit */
nav {
  background: var(--bg-secondary);
  border-bottom: 1px solid var(--bg-tertiary);
}

.card {
  background: var(--bg-secondary);
  border: 1px solid var(--bg-tertiary);
  border-radius: 0;
}

.note-card {
  background: var(--bg-secondary);
  border-left: 2px solid var(--accent);
  padding: 12px;
  margin-bottom: 4px;
}

.note-card:hover {
  background: var(--bg-tertiary);
  border-left-width: 4px;
}

/* Inputs - minimal */
input, textarea, select {
  background: var(--bg-secondary);
  border: 1px solid var(--bg-tertiary);
  color: var(--text-primary);
  font-family: var(--mono);
  font-size: 13px;
  padding: 8px;
  border-radius: 0;
}

input:focus, textarea:focus {
  outline: none;
  border-color: var(--accent);
  box-shadow: none;
}

/* Buttons - sharp */
button, .btn {
  font-family: var(--mono);
  font-size: 12px;
  padding: 8px 16px;
  border: 1px solid var(--bg-tertiary);
  background: var(--bg-secondary);
  color: var(--text-primary);
  border-radius: 0;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 0.1em;
}

button:hover, .btn:hover {
  border-color: var(--accent);
  background: var(--bg-tertiary);
}

.btn-primary {
  background: var(--accent-dim);
  border-color: var(--accent);
  color: var(--text-primary);
}

.btn-primary:hover {
  background: var(--accent);
}

/* Tags - minimal */
.tag-pill {
  font-family: var(--mono);
  font-size: 10px;
  padding: 2px 8px;
  border-radius: 0;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  border: 1px solid;
}

/* Metadata */
.meta {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--text-tertiary);
  letter-spacing: 0.05em;
}

/* Stats */
.stat-value {
  font-family: var(--mono);
  font-size: 32px;
  font-weight: 700;
  color: var(--text-primary);
}

/* Scrollbar */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: var(--bg-primary);
}

::-webkit-scrollbar-thumb {
  background: var(--bg-tertiary);
}

::-webkit-scrollbar-thumb:hover {
  background: var(--accent-dim);
}

/* Remove all animations */
* {
  transition: none !important;
  animation: none !important;
}

/* Precision over polish */
body {
  -webkit-font-smoothing: antialiased;
  text-rendering: optimizeLegibility;
}
CSS

echo "✅ Styles created"
echo ""

echo "Updating Note model..."

cat > app/models/note.rb << 'RUBY'
class Note < ApplicationRecord
  include VepsEventable
  include PgSearch::Model
  
  multisearchable against: [:title, :content]
  
  pg_search_scope :search_by_content,
    against: {
      title: 'A',
      content: 'B'
    },
    using: {
      tsearch: { prefix: true, any_word: true }
    }
  
  belongs_to :user, optional: true
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  has_many :attachments, dependent: :destroy
  
  has_many :outgoing_links, class_name: 'NoteLink', foreign_key: 'source_note_id', dependent: :destroy
  has_many :incoming_links, class_name: 'NoteLink', foreign_key: 'target_note_id', dependent: :destroy
  has_many :linked_notes, through: :outgoing_links, source: :target_note
  
  validates :title, presence: true
  validates :content, presence: true
  
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  
  before_save :extract_wiki_links
  after_save :create_note_links
  
  def deleted?
    deleted_at.present?
  end
  
  def soft_delete
    update(deleted_at: Time.current)
  end
  
  # Content rendering with YOUR syntax
  def content_html
    return '' if content.blank?
    
    # First: Your custom syntax
    text = Syntax::BrainParser.parse(content)
    
    # Then: Markdown (minimal)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer,
      fenced_code_blocks: true,
      no_intra_emphasis: true
    )
    
    # Wiki links
    text = convert_wiki_links(text)
    
    markdown.render(text).html_safe
  end
  
  def wiki_links
    @wiki_links ||= content.scan(/\[\[([^\]]+)\]\]/).flatten.map(&:strip).uniq
  end
  
  def event_evidence
    {
      note_id: id,
      title: title,
      content_length: content&.length || 0,
      has_content: content.present?,
      tag_ids: tag_ids,
      wiki_links: wiki_links,
      deleted: deleted?
    }
  end
  
  private
  
  def extract_wiki_links
    @extracted_links = wiki_links
  end
  
  def create_note_links
    return unless @extracted_links.present?
    
    outgoing_links.destroy_all
    
    @extracted_links.each do |link_title|
      target = Note.active.find_by('LOWER(title) = ?', link_title.downcase)
      next unless target && target.id != id
      
      NoteLink.find_or_create_by!(
        source_note_id: id,
        target_note_id: target.id,
        link_type: 'references'
      )
    end
  end
  
  def convert_wiki_links(text)
    text.gsub(/\[\[([^\]]+)\]\]/) do |match|
      link_title = $1.strip
      target = Note.active.find_by('LOWER(title) = ?', link_title.downcase)
      
      if target
        "<a href='/notes/#{target.id}'>#{link_title}</a>"
      else
        "<span style='color: var(--text-tertiary);'>[[#{link_title}]]</span>"
      end
    end
  end
end
RUBY

echo "✅ Model updated"
echo ""

cat > config/initializers/brain_syntax.rb << 'RUBY'
Rails.application.config.to_prepare do
  require_relative '../../lib/syntax/brain_parser'
end
RUBY

echo "✅ Initializer created"
echo ""

echo "========================================"
echo "  True Custom Syntax Complete!"
echo "========================================"
echo ""
echo "Based on your actual patterns:"
echo "  :: - atomic delimiter (styled, not parsed)"
echo "  (0.1) - the margin, the unaccounted"
echo "  UNMEASURED.XXX - call numbers"
echo "  seq: XXX - sequence numbers"
echo "  SECTION X: - headers"
echo ""
echo "Your voice. Your syntax. Your precision."
echo ""
echo "Restart dev services to activate."
echo ""