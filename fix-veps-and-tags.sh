#!/bin/bash
# Fix VEPS integration and create sample tags

cd second-brain-rails

echo "Fixing Note model..."

# Completely rewrite the Note model with VEPS included
cat > app/models/note.rb << 'RUBY'
class Note < ApplicationRecord
  # VEPS Integration
  include VepsEventable
  
  belongs_to :user, optional: true
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags
  has_many :attachments, dependent: :destroy
  
  has_many :outgoing_links, class_name: 'NoteLink', foreign_key: 'source_note_id', dependent: :destroy
  has_many :incoming_links, class_name: 'NoteLink', foreign_key: 'target_note_id', dependent: :destroy
  has_many :linked_notes, through: :outgoing_links, source: :target_note
  
  validates :title, presence: true
  validates :content, presence: true
  
  # Soft delete
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  
  def deleted?
    deleted_at.present?
  end
  
  def soft_delete
    update(deleted_at: Time.current)
  end
  
  # VEPS event evidence override
  def event_evidence
    {
      note_id: id,
      title: title,
      content_length: content&.length || 0,
      has_content: content.present?,
      tag_ids: tag_ids,
      deleted: deleted?
    }
  end
end
RUBY

echo "✅ Note model fixed"

# Create some sample tags
echo "Creating sample tags..."

cat > db/seeds.rb << 'RUBY'
# Create sample tags
tags = [
  { name: 'Ideas', color: '#3B82F6' },
  { name: 'TODO', color: '#EF4444' },
  { name: 'Work', color: '#10B981' },
  { name: 'Personal', color: '#8B5CF6' },
  { name: 'Learning', color: '#F59E0B' }
]

tags.each do |tag_attrs|
  Tag.find_or_create_by!(name: tag_attrs[:name]) do |tag|
    tag.color = tag_attrs[:color]
  end
end

puts "✅ Created #{Tag.count} tags"
RUBY

RAILS_ENV=development bin/rails db:seed

echo "✅ Sample tags created"
echo ""
echo "Restart your dev server to see VEPS events in logs!"