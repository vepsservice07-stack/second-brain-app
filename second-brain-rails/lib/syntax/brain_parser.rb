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
