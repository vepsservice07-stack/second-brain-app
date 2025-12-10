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
