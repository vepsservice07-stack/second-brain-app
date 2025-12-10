class BulkOperationsController < ApplicationController
  # POST /bulk/tag
  def tag
    note_ids = params[:note_ids] || []
    tag_ids = params[:tag_ids] || []
    
    if note_ids.empty? || tag_ids.empty?
      redirect_back fallback_location: notes_path, alert: 'Select notes and tags'
      return
    end
    
    Note.where(id: note_ids).find_each do |note|
      tag_ids.each do |tag_id|
        note.tags << Tag.find(tag_id) unless note.tag_ids.include?(tag_id.to_i)
      end
    end
    
    redirect_back fallback_location: notes_path, notice: "Tagged #{note_ids.count} notes"
  end
  
  # POST /bulk/delete
  def delete
    note_ids = params[:note_ids] || []
    
    if note_ids.empty?
      redirect_back fallback_location: notes_path, alert: 'Select notes to delete'
      return
    end
    
    Note.where(id: note_ids).find_each(&:soft_delete)
    
    redirect_back fallback_location: notes_path, notice: "Deleted #{note_ids.count} notes"
  end
  
  # POST /bulk/export
  def export
    note_ids = params[:note_ids] || []
    format = params[:format] || 'json'
    
    notes = note_ids.empty? ? Note.active.all : Note.active.where(id: note_ids)
    
    case format
    when 'json'
      send_data notes.to_json(include: [:tags, :attachments]), 
        filename: "notes-export-#{Time.current.to_i}.json",
        type: 'application/json'
    when 'markdown'
      markdown = notes.map { |note| note_to_markdown(note) }.join("\n\n---\n\n")
      send_data markdown,
        filename: "notes-export-#{Time.current.to_i}.md",
        type: 'text/markdown'
    else
      redirect_back fallback_location: notes_path, alert: 'Invalid format'
    end
  end
  
  private
  
  def note_to_markdown(note)
    md = "# #{note.title}\n\n"
    md += "seq: #{note.sequence_number || 'pending'}\n"
    md += "updated: #{note.updated_at.iso8601}\n"
    md += "tags: #{note.tags.map(&:name).join(', ')}\n" if note.tags.any?
    md += "\n---\n\n"
    md += note.content
    md
  end
end
