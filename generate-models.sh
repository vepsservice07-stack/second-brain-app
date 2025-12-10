#!/bin/bash
# Second Brain - Generate Rails Models
# Creates the database schema for notes, tags, attachments, etc.
# Usage: ./generate-models.sh

echo "========================================"
echo "  Generating Rails Models"
echo "========================================"
echo ""

# Check if we're in the Rails app directory
if [ ! -f "bin/rails" ]; then
    if [ -d "second-brain-rails" ]; then
        echo "Entering Rails app directory..."
        cd second-brain-rails
    else
        echo "❌ Error: Not in Rails app directory"
        echo "Run this script from the second-brain-app directory"
        exit 1
    fi
fi

echo "Creating database models..."
echo ""

# Generate Note model
echo "📝 Generating Note model..."
bin/rails generate model Note \
    title:string \
    content:text \
    vector_clock:jsonb \
    sequence_number:bigint \
    user_id:bigint \
    deleted_at:datetime

# Generate Tag model
echo "🏷️  Generating Tag model..."
bin/rails generate model Tag \
    name:string:uniq \
    color:string \
    user_id:bigint

# Generate NoteTags join table
echo "🔗 Generating NoteTags join table..."
bin/rails generate model NoteTag \
    note:references \
    tag:references

# Generate Attachment model
echo "📎 Generating Attachment model..."
bin/rails generate model Attachment \
    note:references \
    filename:string \
    content_type:string \
    storage_url:string \
    file_size:bigint

# Generate NoteLink model (for linking notes together)
echo "🔗 Generating NoteLink model..."
bin/rails generate model NoteLink \
    source_note_id:bigint \
    target_note_id:bigint \
    link_type:string

echo ""
echo "✅ Models generated"
echo ""

echo "Adding indexes and constraints to migrations..."
echo ""

# Find the latest migration files and add custom indexes
# We'll use sed to insert indexes before the closing 'end' of the change method

# Add custom code to the Note migration
NOTE_MIGRATION=$(ls -t db/migrate/*_create_notes.rb | head -n1)
if [ -f "$NOTE_MIGRATION" ]; then
    # Insert indexes before the final 'end' of the change method
    sed -i '/^  end$/i\
\
    add_index :notes, :user_id\
    add_index :notes, :sequence_number, unique: true\
    add_index :notes, :deleted_at\
    add_index :notes, :created_at' "$NOTE_MIGRATION"
    
    echo "✅ Added indexes to Note migration"
fi

# Add indexes to NoteTag migration
NOTETAG_MIGRATION=$(ls -t db/migrate/*_create_note_tags.rb | head -n1)
if [ -f "$NOTETAG_MIGRATION" ]; then
    sed -i '/^  end$/i\
\
    add_index :note_tags, [:note_id, :tag_id], unique: true' "$NOTETAG_MIGRATION"
    
    echo "✅ Added unique index to NoteTag migration"
fi

# Add indexes to NoteLink migration
NOTELINK_MIGRATION=$(ls -t db/migrate/*_create_note_links.rb | head -n1)
if [ -f "$NOTELINK_MIGRATION" ]; then
    sed -i '/^  end$/i\
\
    add_index :note_links, :source_note_id\
    add_index :note_links, :target_note_id\
    add_index :note_links, [:source_note_id, :target_note_id], unique: true' "$NOTELINK_MIGRATION"
    
    echo "✅ Added indexes to NoteLink migration"
fi

echo ""
echo "Updating model associations..."
echo ""

# Update Note model with associations and validations
cat > app/models/note.rb << 'EOF'
class Note < ApplicationRecord
  belongs_to :user, optional: true  # Will implement users later
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
end
EOF

# Update Tag model
cat > app/models/tag.rb << 'EOF'
class Tag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags
  
  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :color, format: { with: /\A#[0-9A-F]{6}\z/i, allow_blank: true }
  
  before_validation :set_default_color, on: :create
  
  private
  
  def set_default_color
    self.color ||= "##{SecureRandom.hex(3)}"
  end
end
EOF

# Update NoteTag model
cat > app/models/note_tag.rb << 'EOF'
class NoteTag < ApplicationRecord
  belongs_to :note
  belongs_to :tag
  
  validates :note_id, uniqueness: { scope: :tag_id }
end
EOF

# Update Attachment model
cat > app/models/attachment.rb << 'EOF'
class Attachment < ApplicationRecord
  belongs_to :note
  
  validates :filename, presence: true
  validates :storage_url, presence: true
  
  def humanized_size
    return "0 B" if file_size.nil? || file_size.zero?
    
    units = ['B', 'KB', 'MB', 'GB']
    size = file_size.to_f
    unit_index = 0
    
    while size >= 1024 && unit_index < units.length - 1
      size /= 1024.0
      unit_index += 1
    end
    
    "#{size.round(2)} #{units[unit_index]}"
  end
end
EOF

# Update NoteLink model
cat > app/models/note_link.rb << 'EOF'
class NoteLink < ApplicationRecord
  belongs_to :source_note, class_name: 'Note'
  belongs_to :target_note, class_name: 'Note'
  
  validates :source_note_id, uniqueness: { scope: :target_note_id }
  validates :link_type, inclusion: { in: %w[references builds_on contradicts related] }
  
  validate :cannot_link_to_self
  
  private
  
  def cannot_link_to_self
    if source_note_id == target_note_id
      errors.add(:target_note_id, "cannot link note to itself")
    end
  end
end
EOF

echo "✅ Model associations and validations added"
echo ""

echo "========================================"
echo "  Model Generation Complete!"
echo "========================================"
echo ""
echo "Database schema created for:"
echo "  📝 Notes (with vector clock and sequence number)"
echo "  🏷️  Tags"
echo "  🔗 Note-Tag associations"
echo "  📎 Attachments"
echo "  🔗 Note-to-Note links"
echo ""
echo "Next steps:"
echo "  1. Review migrations in db/migrate/"
echo "  2. Run: bin/rails db:create db:migrate"
echo "  3. Start building controllers and views!"
echo ""
