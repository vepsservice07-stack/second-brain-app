class SnapshotMaintenanceJob
  include Sidekiq::Job
  
  def perform
    # Create snapshots for notes that need them
    Note.active.find_each do |note|
      # Check if snapshot needed (every 1000 interactions)
      last_snapshot_seq = note.snapshots.maximum(:sequence_number) || 0
      current_seq = note.interactions.maximum(:sequence_number) || 0
      
      if current_seq - last_snapshot_seq > 1000
        EventStore.create_snapshot(note.id)
        Rails.logger.info("Created snapshot for note #{note.id} at seq #{current_seq}")
      end
    end
  end
end
