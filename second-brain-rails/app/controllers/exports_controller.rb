class ExportsController < ApplicationController
  # GET /export/all
  def all
    format = params[:format] || 'json'
    
    case format
    when 'json'
      export_json
    when 'markdown'
      export_markdown
    else
      redirect_to root_path, alert: 'Invalid format'
    end
  end
  
  private
  
  def export_json
    data = {
      exported_at: Time.current.iso8601,
      notes: Note.active.includes(:tags, :attachments).map { |note| note_json(note) },
      tags: Tag.all.map { |tag| tag_json(tag) }
    }
    
    send_data JSON.pretty_generate(data),
      filename: "second-brain-export-#{Time.current.to_i}.json",
      type: 'application/json'
  end
  
  def export_markdown
    markdown = "# SECOND BRAIN EXPORT\n\n"
    markdown += "exported: #{Time.current.iso8601}\n"
    markdown += "notes: #{Note.active.count}\n\n"
    markdown += "---\n\n"
    
    Note.active.order(updated_at: :desc).each do |note|
      markdown += "# #{note.title}\n\n"
      markdown += "seq: #{note.sequence_number || 'pending'}\n"
      markdown += "updated: #{note.updated_at.iso8601}\n"
      markdown += "tags: #{note.tags.map(&:name).join(', ')}\n" if note.tags.any?
      markdown += "\n"
      markdown += note.content
      markdown += "\n\n---\n\n"
    end
    
    send_data markdown,
      filename: "second-brain-export-#{Time.current.to_i}.md",
      type: 'text/markdown'
  end
  
  def note_json(note)
    {
      id: note.id,
      title: note.title,
      content: note.content,
      sequence_number: note.sequence_number,
      tags: note.tags.map { |t| { id: t.id, name: t.name, color: t.color } },
      wiki_links: note.wiki_links,
      created_at: note.created_at.iso8601,
      updated_at: note.updated_at.iso8601
    }
  end
  
  def tag_json(tag)
    {
      id: tag.id,
      name: tag.name,
      color: tag.color,
      note_count: tag.notes.active.count
    }
  end
end
